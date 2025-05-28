#!/usr/bin/env python3

import argparse
import json
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from datetime import datetime
import os

class RecoveryVisualizer:
    def __init__(self, report_file, output_dir):
        self.report_file = report_file
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
        with open(report_file, 'r') as f:
            self.report = json.load(f)
        
        # Set style
        plt.style.use('seaborn')
        sns.set_palette("husl")

    def create_duration_heatmap(self):
        """Create heatmap of recovery durations across environments and scenarios"""
        environments = list(self.report['performance'].keys())
        scenarios = list(self.report['performance'][environments[0]].keys())
        
        data = []
        for env in environments:
            for scenario in scenarios:
                data.append({
                    'Environment': env,
                    'Scenario': scenario,
                    'Duration (min)': self.report['performance'][env][scenario]['avg_duration'] / 60
                })
        
        df = pd.DataFrame(data)
        pivot_table = df.pivot(index='Environment', columns='Scenario', values='Duration (min)')
        
        plt.figure(figsize=(12, 8))
        sns.heatmap(pivot_table, annot=True, fmt='.1f', cmap='YlOrRd')
        plt.title('Recovery Duration Heatmap (minutes)')
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/duration_heatmap.png')
        plt.close()

    def create_error_analysis(self):
        """Create error analysis visualization"""
        environments = list(self.report['performance'].keys())
        scenarios = list(self.report['performance'][environments[0]].keys())
        
        data = []
        for env in environments:
            for scenario in scenarios:
                perf = self.report['performance'][env][scenario]
                data.append({
                    'Environment': env,
                    'Scenario': scenario,
                    'Errors': perf['errors'],
                    'Warnings': perf['warnings'],
                    'Threshold Exceeded': perf['tests_exceeding_threshold']
                })
        
        df = pd.DataFrame(data)
        
        plt.figure(figsize=(15, 6))
        df_melted = pd.melt(df, 
                           id_vars=['Environment', 'Scenario'],
                           value_vars=['Errors', 'Warnings', 'Threshold Exceeded'])
        
        sns.barplot(x='Scenario', y='value', hue='variable', data=df_melted)
        plt.title('Error Analysis by Scenario')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/error_analysis.png')
        plt.close()

    def create_performance_trends(self):
        """Create performance trends visualization"""
        environments = list(self.report['performance'].keys())
        scenarios = list(self.report['performance'][environments[0]].keys())
        
        fig, axes = plt.subplots(len(environments), 1, figsize=(12, 4*len(environments)))
        if len(environments) == 1:
            axes = [axes]
        
        for i, env in enumerate(environments):
            data = []
            for scenario in scenarios:
                perf = self.report['performance'][env][scenario]
                data.append({
                    'Scenario': scenario,
                    'Min': perf['min_duration'] / 60,
                    'Avg': perf['avg_duration'] / 60,
                    'Max': perf['max_duration'] / 60
                })
            
            df = pd.DataFrame(data)
            df.plot(x='Scenario', y=['Min', 'Avg', 'Max'], kind='bar', ax=axes[i])
            axes[i].set_title(f'{env.upper()} Recovery Duration (minutes)')
            axes[i].set_xticklabels(df['Scenario'], rotation=45)
        
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/performance_trends.png')
        plt.close()

    def create_success_rate_chart(self):
        """Create success rate visualization"""
        total = self.report['summary']['total_tests']
        success = self.report['summary']['successful_tests']
        failed = self.report['summary']['failed_tests']
        
        plt.figure(figsize=(8, 8))
        plt.pie([success, failed],
                labels=['Successful', 'Failed'],
                autopct='%1.1f%%',
                colors=['#2ecc71', '#e74c3c'])
        plt.title('Recovery Test Success Rate')
        plt.savefig(f'{self.output_dir}/success_rate.png')
        plt.close()

    def generate_html_report(self):
        """Generate HTML report with visualizations"""
        html_content = f"""
        <html>
        <head>
            <title>Recovery Test Results</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .container {{ max-width: 1200px; margin: 0 auto; }}
                .section {{ margin-bottom: 40px; }}
                .visualization {{ margin: 20px 0; text-align: center; }}
                .recommendations {{ 
                    background-color: #f8f9fa;
                    padding: 20px;
                    border-radius: 5px;
                }}
                .metric {{ 
                    display: inline-block;
                    margin: 10px;
                    padding: 20px;
                    background-color: #ffffff;
                    border: 1px solid #dee2e6;
                    border-radius: 5px;
                    text-align: center;
                }}
                .metric h3 {{ margin: 0; color: #495057; }}
                .metric p {{ margin: 5px 0; font-size: 24px; color: #212529; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Recovery Test Results</h1>
                <div class="section">
                    <h2>Summary Metrics</h2>
                    <div class="metric">
                        <h3>Total Tests</h3>
                        <p>{self.report['summary']['total_tests']}</p>
                    </div>
                    <div class="metric">
                        <h3>Success Rate</h3>
                        <p>{(self.report['summary']['successful_tests'] / self.report['summary']['total_tests'] * 100):.1f}%</p>
                    </div>
                </div>
                
                <div class="section">
                    <h2>Visualizations</h2>
                    <div class="visualization">
                        <h3>Recovery Duration Heatmap</h3>
                        <img src="duration_heatmap.png" alt="Duration Heatmap">
                    </div>
                    <div class="visualization">
                        <h3>Error Analysis</h3>
                        <img src="error_analysis.png" alt="Error Analysis">
                    </div>
                    <div class="visualization">
                        <h3>Performance Trends</h3>
                        <img src="performance_trends.png" alt="Performance Trends">
                    </div>
                    <div class="visualization">
                        <h3>Success Rate</h3>
                        <img src="success_rate.png" alt="Success Rate">
                    </div>
                </div>
                
                <div class="section recommendations">
                    <h2>Recommendations</h2>
                    <ul>
                        {''.join(f'<li>{r}</li>' for r in self.report['recommendations'])}
                    </ul>
                </div>
            </div>
        </body>
        </html>
        """
        
        with open(f'{self.output_dir}/report.html', 'w') as f:
            f.write(html_content)

    def generate_all(self):
        """Generate all visualizations and report"""
        self.create_duration_heatmap()
        self.create_error_analysis()
        self.create_performance_trends()
        self.create_success_rate_chart()
        self.generate_html_report()

def main():
    parser = argparse.ArgumentParser(description='Visualize recovery test results')
    parser.add_argument('--report', required=True, help='JSON report file')
    parser.add_argument('--output-dir', required=True, help='Output directory for visualizations')
    args = parser.parse_args()

    visualizer = RecoveryVisualizer(args.report, args.output_dir)
    visualizer.generate_all()

if __name__ == '__main__':
    main()