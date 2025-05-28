const AWS = require('aws-sdk');
const { performance } = require('perf_hooks');
const fs = require('fs');

// Configure AWS SDK
AWS.config.update({ region: process.env.AWS_REGION || 'ap-south-1' });

// Test configuration
const config = {
  concurrentUsers: parseInt(process.env.CONCURRENT_USERS || '50'),
  requestsPerUser: parseInt(process.env.REQUESTS_PER_USER || '20'),
  delayBetweenRequests: parseInt(process.env.DELAY_BETWEEN_REQUESTS || '100'), // milliseconds
  apiEndpoint: process.env.API_ENDPOINT,
  warmupRequests: parseInt(process.env.WARMUP_REQUESTS || '5'),
  reportFile: process.env.REPORT_FILE || 'load-test-report.json'
};

// Metrics storage
const metrics = {
  successful: 0,
  failed: 0,
  latencies: [],
  errors: {},
  startTime: null,
  endTime: null,
  p50Latency: null,
  p90Latency: null,
  p95Latency: null,
  p99Latency: null,
  minLatency: null,
  maxLatency: null,
  avgLatency: null,
  requestsPerSecond: null
};

// Helper to calculate percentile
function calculatePercentile(latencies, percentile) {
  const sorted = [...latencies].sort((a, b) => a - b);
  const index = Math.ceil((percentile / 100) * sorted.length) - 1;
  return sorted[index];
}

// Helper to make a request with IAM signing
async function makeRequest(requestId) {
  const endpoint = new URL(config.apiEndpoint);
  const request = new AWS.HttpRequest(endpoint, AWS.config.region);
  
  request.method = 'POST';
  request.headers['Content-Type'] = 'application/json';
  request.headers['Host'] = endpoint.host;
  request.headers['X-Request-ID'] = requestId;
  request.body = JSON.stringify({
    data: {
      timestamp: new Date().toISOString(),
      requestId,
      test: 'load-test'
    }
  });

  const signer = new AWS.Signers.V4(request, 'execute-api');
  signer.addAuthorization(AWS.config.credentials, new Date());

  const startTime = performance.now();
  
  try {
    const response = await fetch(endpoint.toString(), {
      method: request.method,
      headers: request.headers,
      body: request.body
    });

    const endTime = performance.now();
    const latency = endTime - startTime;

    if (response.ok) {
      metrics.successful++;
      metrics.latencies.push(latency);
    } else {
      metrics.failed++;
      const errorKey = `${response.status}: ${response.statusText}`;
      metrics.errors[errorKey] = (metrics.errors[errorKey] || 0) + 1;
      console.error(`Request ${requestId} failed with status ${response.status}`);
    }

    return { latency, status: response.status };
  } catch (error) {
    metrics.failed++;
    const errorKey = `Error: ${error.message}`;
    metrics.errors[errorKey] = (metrics.errors[errorKey] || 0) + 1;
    console.error(`Request ${requestId} failed with error:`, error.message);
    return { error: error.message };
  }
}

// Warm up the Lambda function
async function warmup() {
  console.log(`Warming up with ${config.warmupRequests} requests...`);
  const warmupPromises = Array(config.warmupRequests)
    .fill(null)
    .map((_, i) => makeRequest(`warmup-${i}`));
  
  await Promise.all(warmupPromises);
  console.log('Warmup completed');
  
  // Reset metrics after warmup
  metrics.successful = 0;
  metrics.failed = 0;
  metrics.latencies = [];
  metrics.errors = {};
}

// Run a single user's requests
async function runUserRequests(userId) {
  for (let i = 0; i < config.requestsPerUser; i++) {
    const requestId = `user-${userId}-request-${i}`;
    await makeRequest(requestId);
    await new Promise(resolve => setTimeout(resolve, config.delayBetweenRequests));
  }
}

// Calculate final metrics
function calculateMetrics() {
  const totalRequests = metrics.successful + metrics.failed;
  metrics.p50Latency = calculatePercentile(metrics.latencies, 50);
  metrics.p90Latency = calculatePercentile(metrics.latencies, 90);
  metrics.p95Latency = calculatePercentile(metrics.latencies, 95);
  metrics.p99Latency = calculatePercentile(metrics.latencies, 99);
  metrics.minLatency = Math.min(...metrics.latencies);
  metrics.maxLatency = Math.max(...metrics.latencies);
  metrics.avgLatency = metrics.latencies.reduce((a, b) => a + b, 0) / metrics.latencies.length;
  
  const durationSeconds = (metrics.endTime - metrics.startTime) / 1000;
  metrics.requestsPerSecond = totalRequests / durationSeconds;
  
  return {
    totalRequests,
    successRate: (metrics.successful / totalRequests) * 100,
    failureRate: (metrics.failed / totalRequests) * 100,
    durationSeconds,
    ...metrics
  };
}

// Generate report
function generateReport(results) {
  const report = {
    config,
    results,
    timestamp: new Date().toISOString()
  };

  fs.writeFileSync(config.reportFile, JSON.stringify(report, null, 2));
  
  console.log('\nLoad Test Results:');
  console.log('==================');
  console.log(`Total Requests: ${results.totalRequests}`);
  console.log(`Success Rate: ${results.successRate.toFixed(2)}%`);
  console.log(`Requests/Second: ${results.requestsPerSecond.toFixed(2)}`);
  console.log(`Duration: ${results.durationSeconds.toFixed(2)}s`);
  console.log('\nLatency (ms):');
  console.log(`  Min: ${results.minLatency.toFixed(2)}`);
  console.log(`  Avg: ${results.avgLatency.toFixed(2)}`);
  console.log(`  P50: ${results.p50Latency.toFixed(2)}`);
  console.log(`  P90: ${results.p90Latency.toFixed(2)}`);
  console.log(`  P95: ${results.p95Latency.toFixed(2)}`);
  console.log(`  P99: ${results.p99Latency.toFixed(2)}`);
  console.log(`  Max: ${results.maxLatency.toFixed(2)}`);
  
  if (Object.keys(results.errors).length > 0) {
    console.log('\nErrors:');
    Object.entries(results.errors).forEach(([error, count]) => {
      console.log(`  ${error}: ${count}`);
    });
  }
  
  console.log(`\nDetailed report saved to ${config.reportFile}`);
}

// Main load test function
async function runLoadTest() {
  if (!config.apiEndpoint) {
    throw new Error('API_ENDPOINT environment variable is required');
  }

  console.log('Starting load test with configuration:', config);
  
  await warmup();
  
  metrics.startTime = performance.now();
  
  // Create array of promises for concurrent users
  const userPromises = Array(config.concurrentUsers)
    .fill(null)
    .map((_, i) => runUserRequests(i));

  // Wait for all users to complete their requests
  await Promise.all(userPromises);
  
  metrics.endTime = performance.now();
  
  const results = calculateMetrics();
  generateReport(results);
  
  return results;
}

// Run the load test
runLoadTest().catch(error => {
  console.error('Load test failed:', error);
  process.exit(1);
});