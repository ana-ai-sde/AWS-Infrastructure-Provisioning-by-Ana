#!/usr/bin/env python3

import argparse
import json
import os
import re
from datetime import datetime
from collections import defaultdict

class RecoveryAnalyzer:
    def __init__(self, results_dir):
        self.results_dir = results_dir
        self.metrics = defaultdict(lambda: defaultdict(list))
        self.thresholds = {
            'prod': {
                'full_cluster_recovery': 3600,    # 1 hour
                'partial_recovery': 1800,         # 30 minutes
                'component_recovery': 900         # 15 minutes
            },
            'staging': {
                'full_cluster_recovery': 2700,    # 45 minutes
                'partial_recovery': 1200,         # 20 minutes
                'component_recovery': 600         # 10 minutes
            },
            'dev': {
                'full_cluster_recovery': 1800,    # 30 minutes
                'partial_recovery': 900,          # 15 minutes
                'component_recovery': 300         # 5 minutes
            }
        }

    def parse_log_file(self, file_path):
        metrics = {
            'start_time': None,
            'end_time': None,
            'steps': [],
            'errors': [],
            'warnings': []
        }

        with open(file_path, 'r') as f:
            for line in f:
                timestamp_match = re.search(r'\[([\d-]+ [\d:]+)\]', line)
                if timestamp_match:
                    timestamp = datetime.strptime(timestamp_match.group(1), '%Y-%m-%d %H:%M:%S')
                    
                    if metrics['start_time'] is None:
                        metrics['start_time'] = timestamp
                    metrics['end_time'] = timestamp

                    if '[ERROR]' in line:
                        metrics['errors'].append(line.strip())
                    elif '[WARN]' in line:
                        metrics['warnings'].append(line.strip())
                    
                    if 'Starting' in line:
                        metrics['steps'].append({
                            'name': line.split('Starting')[-1].strip(),
                            'start_time': timestamp
                        })
                    elif 'Completed' in line and metrics['steps']:
                        metrics['steps'][-1]['end_time'] = timestamp

        return metrics

    def analyze_performance(self):
        for root, _, files in os.walk(self.results_dir):
            for file in files:
                if file.endswith('.log'):
                    path_parts = root.split(os.sep)
                    env = path_parts[-2]
                    scenario = path_parts[-1]
                    
                    metrics = self.parse_log_file(os.path.join(root, file))
                    if metrics['start_time'] and metrics['end_time']:
                        duration = (metrics['end_time'] - metrics['start_time']).total_seconds()
                        self.metrics[env][scenario].append({
                            'duration': duration,
                            'errors': len(metrics['errors']),
                            'warnings': len(metrics['warnings']),
                            'steps': len(metrics['steps']),
                            'threshold_exceeded': duration > self.thresholds[env][scenario]
                        })

    def generate_report(self):
        report = {
            'summary': {
                'total_tests': 0,
                'successful_tests': 0,
                'failed_tests': 0
            },
            'performance': defaultdict(lambda: defaultdict(dict)),
            'recommendations': []
        }

        for env in self.metrics:
            for scenario in self.metrics[env]:
                tests = self.metrics[env][scenario]
                report['summary']['total_tests'] += len(tests)
                
                durations = [t['duration'] for t in tests]
                errors = sum(t['errors'] for t in tests)
                warnings = sum(t['warnings'] for t in tests)
                threshold_exceeded = sum(1 for t in tests if t['threshold_exceeded'])

                report['performance'][env][scenario] = {
                    'avg_duration': sum(durations) / len(durations),
                    'min_duration': min(durations),
                    'max_duration': max(durations),
                    'errors': errors,
                    'warnings': warnings,
                    'tests_exceeding_threshold': threshold_exceeded
                }

                report['summary']['failed_tests'] += threshold_exceeded
                report['summary']['successful_tests'] = (
                    report['summary']['total_tests'] - report['summary']['failed_tests']
                )

                # Generate recommendations
                if threshold_exceeded > 0:
                    report['recommendations'].append(
                        f"Optimize {scenario} recovery in {env} environment - "
                        f"{threshold_exceeded} tests exceeded threshold"
                    )
                if errors > 0:
                    report['recommendations'].append(
                        f"Investigate errors in {scenario} recovery for {env} environment - "
                        f"{errors} errors detected"
                    )

        return report

def main():
    parser = argparse.ArgumentParser(description='Analyze recovery test results')
    parser.add_argument('--results-dir', required=True, help='Directory containing test results')
    parser.add_argument('--output', required=True, help='Output file for benchmark report')
    args = parser.parse_args()

    analyzer = RecoveryAnalyzer(args.results_dir)
    analyzer.analyze_performance()
    report = analyzer.generate_report()

    with open(args.output, 'w') as f:
        json.dump(report, f, indent=2)

if __name__ == '__main__':
    main()