'use client';

import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type DeviceType = 'iphone-14' | 'iphone-se' | 'android';

interface DeviceConfig {
  name: string;
  width: number;
  height: number;
  borderRadius: number;
  notchWidth?: number;
  notchHeight?: number;
  hasHomeIndicator?: boolean;
}

const DEVICE_CONFIGS: Record<DeviceType, DeviceConfig> = {
  'iphone-14': {
    name: 'iPhone 14',
    width: 390,
    height: 844,
    borderRadius: 47,
    notchWidth: 126,
    notchHeight: 34,
    hasHomeIndicator: true,
  },
  'iphone-se': {
    name: 'iPhone SE',
    width: 375,
    height: 667,
    borderRadius: 40,
    hasHomeIndicator: false,
  },
  'android': {
    name: 'Android',
    width: 412,
    height: 915,
    borderRadius: 20,
    hasHomeIndicator: true,
  },
};

interface MobileDeviceFrameProps {
  children: ReactNode;
  device?: DeviceType;
  scale?: number;
  showStatusBar?: boolean;
  statusBarTime?: string;
  className?: string;
}

export function MobileDeviceFrame({
  children,
  device = 'iphone-14',
  scale = 0.6,
  showStatusBar = true,
  statusBarTime = '9:41',
  className,
}: MobileDeviceFrameProps) {
  const config = DEVICE_CONFIGS[device];
  const scaledWidth = config.width * scale;
  const scaledHeight = config.height * scale;

  return (
    <div
      className={cn('relative flex-shrink-0', className)}
      style={{
        width: scaledWidth,
        height: scaledHeight,
      }}
    >
      {/* Outer device frame */}
      <div
        className="absolute inset-0 bg-gray-900 dark:bg-gray-800"
        style={{
          borderRadius: config.borderRadius * scale,
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25), 0 0 0 1px rgba(0, 0, 0, 0.1)',
        }}
      >
        {/* Side buttons */}
        <div
          className="absolute bg-gray-800 dark:bg-gray-700"
          style={{
            left: -3,
            top: 100 * scale,
            width: 3,
            height: 30 * scale,
            borderRadius: '2px 0 0 2px',
          }}
        />
        <div
          className="absolute bg-gray-800 dark:bg-gray-700"
          style={{
            left: -3,
            top: 150 * scale,
            width: 3,
            height: 60 * scale,
            borderRadius: '2px 0 0 2px',
          }}
        />
        <div
          className="absolute bg-gray-800 dark:bg-gray-700"
          style={{
            left: -3,
            top: 220 * scale,
            width: 3,
            height: 60 * scale,
            borderRadius: '2px 0 0 2px',
          }}
        />
        <div
          className="absolute bg-gray-800 dark:bg-gray-700"
          style={{
            right: -3,
            top: 170 * scale,
            width: 3,
            height: 80 * scale,
            borderRadius: '0 2px 2px 0',
          }}
        />

        {/* Screen bezel */}
        <div
          className="absolute bg-black overflow-hidden"
          style={{
            top: 12 * scale,
            left: 12 * scale,
            right: 12 * scale,
            bottom: 12 * scale,
            borderRadius: (config.borderRadius - 10) * scale,
          }}
        >
          {/* Status bar */}
          {showStatusBar && (
            <div
              className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between px-6 text-white"
              style={{
                height: 44 * scale,
                fontSize: 14 * scale,
                paddingLeft: 24 * scale,
                paddingRight: 24 * scale,
              }}
            >
              <span className="font-semibold">{statusBarTime}</span>
              <div className="flex items-center gap-1">
                {/* Signal bars */}
                <svg
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  style={{ width: 16 * scale, height: 16 * scale }}
                >
                  <rect x="1" y="14" width="4" height="6" rx="1" />
                  <rect x="7" y="10" width="4" height="10" rx="1" />
                  <rect x="13" y="6" width="4" height="14" rx="1" />
                  <rect x="19" y="2" width="4" height="18" rx="1" />
                </svg>
                {/* WiFi */}
                <svg
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  style={{ width: 16 * scale, height: 16 * scale }}
                >
                  <path d="M12 18c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2zm-4.24-4.24l1.42 1.42c1.56-1.56 4.08-1.56 5.64 0l1.42-1.42c-2.34-2.34-6.14-2.34-8.48 0zM5.64 11.64l1.42 1.42c2.73-2.73 7.15-2.73 9.88 0l1.42-1.42c-3.51-3.51-9.21-3.51-12.72 0zM3.52 9.52l1.42 1.42c3.9-3.9 10.22-3.9 14.12 0l1.42-1.42c-4.68-4.68-12.28-4.68-16.96 0z" />
                </svg>
                {/* Battery */}
                <svg
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  style={{ width: 24 * scale, height: 16 * scale }}
                >
                  <rect x="2" y="7" width="18" height="10" rx="2" stroke="currentColor" strokeWidth="2" fill="none" />
                  <rect x="4" y="9" width="14" height="6" rx="1" />
                  <rect x="20" y="10" width="2" height="4" rx="0.5" />
                </svg>
              </div>
            </div>
          )}

          {/* Dynamic Island / Notch */}
          {config.notchWidth && config.notchHeight && (
            <div
              className="absolute z-20 bg-black"
              style={{
                top: 10 * scale,
                left: '50%',
                transform: 'translateX(-50%)',
                width: config.notchWidth * scale,
                height: config.notchHeight * scale,
                borderRadius: (config.notchHeight / 2) * scale,
              }}
            />
          )}

          {/* Screen content */}
          <div
            className="absolute overflow-hidden bg-white dark:bg-gray-950"
            style={{
              top: showStatusBar ? 44 * scale : 0,
              left: 0,
              right: 0,
              bottom: config.hasHomeIndicator ? 34 * scale : 0,
            }}
          >
            <div
              style={{
                width: config.width - 24,
                height: config.height - (showStatusBar ? 44 : 0) - (config.hasHomeIndicator ? 34 : 0) - 24,
                transform: `scale(${scale})`,
                transformOrigin: 'top left',
              }}
            >
              {children}
            </div>
          </div>

          {/* Home indicator */}
          {config.hasHomeIndicator && (
            <div
              className="absolute z-10 bg-white/30 rounded-full"
              style={{
                bottom: 8 * scale,
                left: '50%',
                transform: 'translateX(-50%)',
                width: 134 * scale,
                height: 5 * scale,
              }}
            />
          )}
        </div>
      </div>
    </div>
  );
}

// Device selector component
interface DeviceSelectorProps {
  value: DeviceType;
  onChange: (device: DeviceType) => void;
  className?: string;
}

export function DeviceSelector({
  value,
  onChange,
  className,
}: DeviceSelectorProps) {
  return (
    <div className={cn('flex items-center gap-2', className)}>
      {(Object.entries(DEVICE_CONFIGS) as [DeviceType, DeviceConfig][]).map(
        ([key, config]) => (
          <button
            key={key}
            onClick={() => onChange(key)}
            className={cn(
              'px-3 py-1.5 text-sm rounded-md transition-colors',
              value === key
                ? 'bg-primary text-primary-foreground'
                : 'bg-muted hover:bg-muted/80 text-muted-foreground'
            )}
          >
            {config.name}
          </button>
        )
      )}
    </div>
  );
}

export type { DeviceType };
