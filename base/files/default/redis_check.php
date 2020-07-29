#!/usr/bin/php
<?php
//Current instance configurations
define('CURRENT_IP', $argv[1]);
define('CURRENT_PORT', $argv[2]);

// Check if the client is responding
$ping = runRedisCommand('ping');
if (!isset($ping[0]) || $ping[0] != 'PONG')
    exit(2);

// Test setting a key
$output = runRedisCommand('SET consul:health:redis "' . uniqid() . '"');
if ($output[0] != 'OK')
    exit(2);

exit(0);

/**
 * Execute a redis command and return the output of it
 * @param  string $command
 * @param  string $port
 * @param  string $ip
 * @return array
 */
function runRedisCommand($command, $port = CURRENT_PORT, $ip = CURRENT_IP)
{
    exec('redis-cli -p ' . $port . ' -h ' . $ip . ' ' . $command, $output);
    return $output;
}
