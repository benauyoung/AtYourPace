import { DashboardCharts } from '@/components/dashboard/dashboard-charts';
import { RecentActivity } from '@/components/dashboard/recent-activity';
import { render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

// Mock Recharts to avoid resizing issues in JSDOM
// Recharts uses ResizeObserver which works poorly in JSDOM default env
vi.mock('recharts', async (importOriginal) => {
    const actual = await importOriginal<any>();
    return {
        ...actual,
        ResponsiveContainer: ({ children }: any) => <div className="recharts-responsive-container">{children}</div>,
    };
});

// Mock hooks
const mockRevenueData = {
    totalRevenue: 12450,
    monthlyRevenue: 3200,
    growth: 12.5,
    history: [
        { date: 'Jan 1', value: 100 },
        { date: 'Jan 2', value: 150 },
    ],
};

const mockUserGrowthData = {
    totalUsers: 8540,
    newUsersThisMonth: 420,
    history: [
        { date: 'Jan 1', value: 50 },
        { date: 'Jan 2', value: 60 },
    ],
};

const mockAuditLogs = [
    {
        id: '1',
        adminId: 'admin1',
        adminEmail: 'admin@example.com',
        action: 'tourApproved',
        targetId: 'tour123',
        targetType: 'tour',
        timestamp: new Date().toISOString(), // Serialized date
        details: {},
    },
    {
        id: '2',
        adminId: 'admin1',
        adminEmail: 'admin@example.com',
        action: 'userBanned',
        targetId: 'user456',
        targetType: 'user',
        timestamp: new Date(Date.now() - 10000).toISOString(),
        details: {},
    },
];

vi.mock('@/hooks/use-analytics', () => ({
    useRevenueAnalytics: vi.fn(),
    useUserGrowthAnalytics: vi.fn(),
}));

vi.mock('@/hooks/use-audit-logs', () => ({
    useAuditLogs: vi.fn(),
}));

import { useRevenueAnalytics, useUserGrowthAnalytics } from '@/hooks/use-analytics';
import { useAuditLogs } from '@/hooks/use-audit-logs';

describe('Dashboard Components (Phase E)', () => {
    beforeEach(() => {
        vi.resetAllMocks();
    });

    describe('DashboardCharts', () => {
        it('renders loading skeletons initially', () => {
            (useRevenueAnalytics as any).mockReturnValue({
                data: null,
                isLoading: true,
            });
            (useUserGrowthAnalytics as any).mockReturnValue({
                data: null,
                isLoading: true,
            });

            const { container } = render(<DashboardCharts />);
            // Check for pulse animation class which indicates skeleton
            expect(container.getElementsByClassName('animate-pulse').length).toBeGreaterThan(0);
        });

        it('renders charts when data is loaded', async () => {
            (useRevenueAnalytics as any).mockReturnValue({
                data: mockRevenueData,
                isLoading: false,
            });
            (useUserGrowthAnalytics as any).mockReturnValue({
                data: mockUserGrowthData,
                isLoading: false,
            });

            render(<DashboardCharts />);

            expect(screen.getByText('Revenue Overview')).toBeInTheDocument();
            expect(screen.getByText('User Growth')).toBeInTheDocument();
            // Verify Recharts containers exist
            expect(document.getElementsByClassName('recharts-responsive-container')).toHaveLength(2);
        });
    });

    describe('RecentActivity', () => {
        it('renders loading skeletons initially', () => {
            (useAuditLogs as any).mockReturnValue({
                data: null,
                isLoading: true,
            });

            const { container } = render(<RecentActivity />);
            expect(screen.queryByText('Recent Activity')).not.toBeInTheDocument(); // Title is inside component that returns skeleton
            expect(container.getElementsByClassName('animate-pulse').length).toBeGreaterThan(0);
        });

        it('renders activity items when data is loaded', async () => {
            // Mock date processing
            const logsWithDateObjects = mockAuditLogs.map(log => ({
                ...log,
                timestamp: new Date(log.timestamp) // Hook usually returns Date objects
            }));

            (useAuditLogs as any).mockReturnValue({
                data: logsWithDateObjects,
                isLoading: false,
            });

            render(<RecentActivity />);

            expect(screen.getByText('Recent Activity')).toBeInTheDocument();
            expect(screen.getByText('Approved tour #tour12')).toBeInTheDocument();
            expect(screen.getByText('Banned user #user45')).toBeInTheDocument();
            expect(screen.getAllByText(/admin@example.com/)).toHaveLength(2);
        });

        it('renders empty state when no logs', () => {
            (useAuditLogs as any).mockReturnValue({
                data: [],
                isLoading: false,
            });

            render(<RecentActivity />);
            expect(screen.getByText('No recent activity.')).toBeInTheDocument();
        });
    });
});
