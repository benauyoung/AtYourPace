'use client';

import { Button } from '@/components/ui/button';
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form';
import { Textarea } from '@/components/ui/textarea';
import { TourVersionModel } from '@/types';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';

const tipsFormSchema = z.object({
    startLocationInstructions: z.string().optional(),
    bestTime: z.string().optional(),
    precautions: z.string().optional(),
    foodOptions: z.string().optional(),
});

type TipsFormValues = z.infer<typeof tipsFormSchema>;

interface TipsFormProps {
    version: TourVersionModel;
    onSave: (data: Partial<TourVersionModel>) => Promise<void>;
    isSaving?: boolean;
}

export function TipsForm({ version, onSave, isSaving }: TipsFormProps) {
    const form = useForm<TipsFormValues>({
        resolver: zodResolver(tipsFormSchema),
        defaultValues: {
            startLocationInstructions: version.startLocationInstructions || '',
            bestTime: version.bestTime || '',
            precautions: version.precautions || '',
            foodOptions: version.foodOptions || '',
        },
    });

    useEffect(() => {
        form.reset({
            startLocationInstructions: version.startLocationInstructions || '',
            bestTime: version.bestTime || '',
            precautions: version.precautions || '',
            foodOptions: version.foodOptions || '',
        });
    }, [version, form]);

    const handleSubmit = async (data: TipsFormValues) => {
        await onSave(data);
    };

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8 max-w-3xl">
                <div className="space-y-6">
                    <div className="space-y-2">
                        <h3 className="text-lg font-medium text-red-500 flex items-center gap-2">
                            <span className="text-xl">☀</span> Tips
                        </h3>
                        <p className="text-sm text-muted-foreground">
                            Helpful information for listeners before they start.
                        </p>
                    </div>

                    <div className="space-y-6">
                        <FormField
                            control={form.control}
                            name="startLocationInstructions"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel className="text-base">Directions to starting point</FormLabel>
                                    <FormDescription>
                                        The app has a button that will open Apple or Google Maps... Use this to give listeners tips on how to get there most easily.
                                    </FormDescription>
                                    <FormControl>
                                        <Textarea
                                            placeholder="e.g. The tour begins in the north parking lot..."
                                            className="min-h-[100px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="bestTime"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel className="text-base">Best time</FormLabel>
                                    <FormDescription>
                                        What is the best time to do this tour? Can you do it all year?
                                    </FormDescription>
                                    <FormControl>
                                        <Textarea
                                            placeholder="e.g. From dawn to dusk..."
                                            className="min-h-[80px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="precautions"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel className="text-base">Precautions</FormLabel>
                                    <FormDescription>
                                        Do you need to give alert listeners to anything that might prevent them from completing the tour safely?
                                    </FormDescription>
                                    <FormControl>
                                        <Textarea
                                            placeholder="e.g. Be very aware of your surroundings..."
                                            className="min-h-[80px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="foodOptions"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel className="text-base">Places to stop along the way</FormLabel>
                                    <FormDescription>
                                        Is there anywhere worth stopping at on this tour? Museums, galleries, bars, restaurants?
                                    </FormDescription>
                                    <FormControl>
                                        <Textarea
                                            placeholder="e.g. If you're in the mood for a sit-down meal..."
                                            className="min-h-[80px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                    </div>
                </div>

                <div className="flex justify-end">
                    <Button type="submit" disabled={isSaving || !form.formState.isDirty}>
                        {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                        Save Changes
                    </Button>
                </div>
            </form>
        </Form>
    );
}
