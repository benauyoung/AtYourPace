import { useQuery } from '@tanstack/react-query';

export interface AnalyticsDataPoint {
    date: string;
    value: number;
}

export interface RevenueData {
    totalRevenue: number;
    monthlyRevenue: number;
    growth: number;
    history: AnalyticsDataPoint[];
}

export interface UserGrowthData {
    totalUsers: number;
    newUsersThisMonth: number;
    history: AnalyticsDataPoint[];
}

// Mock Data Generators
function generateMockHistory(days: number, startValue: number, volatility: number): AnalyticsDataPoint[] {
    const data: AnalyticsDataPoint[] = [];
    let currentValue = startValue;
    const now = new Date();

    for (let i = days; i >= 0; i--) {
        const date = new Date(now);
        date.setDate(date.getDate() - i);

        // Add some random variation
        const change = (Math.random() - 0.4) * volatility;
        currentValue = Math.max(0, Math.round(currentValue + change));

        data.push({
            date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
            value: currentValue,
        });
    }
    return data;
}

const mockRevenueData: RevenueData = {
    totalRevenue: 12450,
    monthlyRevenue: 3200,
    growth: 12.5,
    history: generateMockHistory(30, 100, 50), // 30 days of data
};

const mockUserGrowthData: UserGrowthData = {
    totalUsers: 8540,
    newUsersThisMonth: 420,
    history: generateMockHistory(30, 20, 10).map(d => ({ ...d, value: Math.round(d.value / 5) })), // Scaling down for user counts
};

export function useRevenueAnalytics() {
    return useQuery({
        queryKey: ['analytics', 'revenue'],
        queryFn: async () => {
            // Simulate network delay
            await new Promise(resolve => setTimeout(resolve, 800));
            return mockRevenueData;
        },
    });
}

export function useUserGrowthAnalytics() {
    return useQuery({
        queryKey: ['analytics', 'userGrowth'],
        queryFn: async () => {
            // Simulate network delay
            await new Promise(resolve => setTimeout(resolve, 600));
            return mockUserGrowthData;
        },
    });
}
