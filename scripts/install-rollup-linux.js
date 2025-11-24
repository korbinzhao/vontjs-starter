#!/usr/bin/env node

/**
 * 为 Vercel Linux 环境安装 Rollup 的 Linux x64 依赖
 * 这个脚本会在 Linux 环境中自动安装所需的 native 依赖
 */

import { execSync } from 'child_process';
import { platform, arch } from 'os';

const isLinux = platform() === 'linux';
const isX64 = arch() === 'x64';

if (isLinux && isX64) {
  console.log('🔧 Detected Linux x64 environment, installing @rollup/rollup-linux-x64-gnu...');
  try {
    execSync('npm install --no-save @rollup/rollup-linux-x64-gnu@^4.53.0', {
      stdio: 'inherit'
    });
    console.log('✅ Successfully installed @rollup/rollup-linux-x64-gnu');
  } catch (error) {
    console.warn('⚠️  Failed to install @rollup/rollup-linux-x64-gnu:', error.message);
    console.warn('⚠️  This may cause runtime errors on Vercel');
  }
} else {
  console.log(`ℹ️  Skipping @rollup/rollup-linux-x64-gnu installation (platform: ${platform()}, arch: ${arch()})`);
}

