'use client';

import { useEffect, useState } from 'react';
import { Save, Loader2 } from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';
import { useToast } from '@/hooks/use-toast';
import { useAppSettings, useUpdateAppSettings } from '@/hooks/use-settings';
import { AppSettings } from '@/types';

export default function SettingsPage() {
  const { toast } = useToast();
  const { data: settings, isLoading } = useAppSettings();
  const updateMutation = useUpdateAppSettings();

  const [formData, setFormData] = useState<AppSettings>({
    maintenanceMode: false,
    registrationEnabled: true,
    maxToursPerCreator: 10,
    elevenLabsQuota: 100,
    minAppVersion: '1.0.0',
    latestAppVersion: '1.0.0',
  });

  useEffect(() => {
    if (settings) {
      setFormData(settings);
    }
  }, [settings]);

  const handleSave = async () => {
    try {
      await updateMutation.mutateAsync(formData);
      toast({
        title: 'Settings saved',
        description: 'Your changes have been saved successfully.',
      });
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to save settings. Please try again.',
      });
    }
  };

  if (isLoading) {
    return (
      <AdminLayout title="Settings">
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout title="Settings">
      <div className="space-y-6">
        {/* Maintenance Mode */}
        <Card>
          <CardHeader>
            <CardTitle>Maintenance Mode</CardTitle>
            <CardDescription>
              When enabled, users will see a maintenance message and won&apos;t be
              able to access the app.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label htmlFor="maintenance">Enable Maintenance Mode</Label>
                <p className="text-sm text-muted-foreground">
                  Temporarily disable access to the app
                </p>
              </div>
              <Switch
                id="maintenance"
                checked={formData.maintenanceMode}
                onCheckedChange={(checked) =>
                  setFormData((prev) => ({ ...prev, maintenanceMode: checked }))
                }
              />
            </div>
          </CardContent>
        </Card>

        {/* Registration Settings */}
        <Card>
          <CardHeader>
            <CardTitle>Registration Settings</CardTitle>
            <CardDescription>
              Control user registration and account creation.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label htmlFor="registration">Allow New Registrations</Label>
                <p className="text-sm text-muted-foreground">
                  New users can create accounts
                </p>
              </div>
              <Switch
                id="registration"
                checked={formData.registrationEnabled}
                onCheckedChange={(checked) =>
                  setFormData((prev) => ({ ...prev, registrationEnabled: checked }))
                }
              />
            </div>
          </CardContent>
        </Card>

        {/* Quotas */}
        <Card>
          <CardHeader>
            <CardTitle>Quotas & Limits</CardTitle>
            <CardDescription>
              Configure usage limits for the platform.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="maxTours">Max Tours per Creator</Label>
                <Input
                  id="maxTours"
                  type="number"
                  min={1}
                  max={100}
                  value={formData.maxToursPerCreator}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      maxToursPerCreator: parseInt(e.target.value) || 10,
                    }))
                  }
                />
                <p className="text-xs text-muted-foreground">
                  Maximum number of tours a creator can have
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="elevenLabsQuota">ElevenLabs Daily Quota</Label>
                <Input
                  id="elevenLabsQuota"
                  type="number"
                  min={0}
                  max={10000}
                  value={formData.elevenLabsQuota}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      elevenLabsQuota: parseInt(e.target.value) || 100,
                    }))
                  }
                />
                <p className="text-xs text-muted-foreground">
                  Daily AI voice generation limit (characters)
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* App Version */}
        <Card>
          <CardHeader>
            <CardTitle>App Version Control</CardTitle>
            <CardDescription>
              Manage minimum required and latest app versions.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="minVersion">Minimum Required Version</Label>
                <Input
                  id="minVersion"
                  value={formData.minAppVersion}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      minAppVersion: e.target.value,
                    }))
                  }
                  placeholder="1.0.0"
                />
                <p className="text-xs text-muted-foreground">
                  Users with older versions will be forced to update
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="latestVersion">Latest Version</Label>
                <Input
                  id="latestVersion"
                  value={formData.latestAppVersion}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      latestAppVersion: e.target.value,
                    }))
                  }
                  placeholder="1.0.0"
                />
                <p className="text-xs text-muted-foreground">
                  Users will be notified about available updates
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Save Button */}
        <div className="flex justify-end">
          <Button onClick={handleSave} disabled={updateMutation.isPending}>
            {updateMutation.isPending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                Save Changes
              </>
            )}
          </Button>
        </div>
      </div>
    </AdminLayout>
  );
}
