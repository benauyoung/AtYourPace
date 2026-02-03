'use client';

import { AdminLayout } from '@/components/layout/admin-layout';
import { MediaGrid } from '@/components/media/media-grid';
import { MediaUploader } from '@/components/media/media-uploader';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useState } from 'react';

export default function MediaPage() {
    const [activeTab, setActiveTab] = useState('uploads');

    return (
        <AdminLayout title="Media Library">
            <div className="space-y-6">
                <div className="flex items-center justify-between">
                    <h2 className="text-lg font-medium tracking-tight">Assets</h2>
                </div>

                <MediaUploader path={activeTab} />

                <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                    <TabsList>
                        <TabsTrigger value="uploads">Uploads</TabsTrigger>
                        <TabsTrigger value="users">User Content</TabsTrigger>
                    </TabsList>

                    <TabsContent value="uploads" className="mt-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Recent Uploads</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <MediaGrid path="uploads" />
                            </CardContent>
                        </Card>
                    </TabsContent>

                    <TabsContent value="users" className="mt-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>User Profile Images</CardTitle>
                            </CardHeader>
                            <CardContent>
                                {/* For demo purposes, we point to a 'users' folder even if empty */}
                                <MediaGrid path="users" />
                            </CardContent>
                        </Card>
                    </TabsContent>
                </Tabs>
            </div>
        </AdminLayout>
    );
}
