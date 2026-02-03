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
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { TourVersionModel } from '@/types';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { CoverImageUpload } from '../cover-image-upload';

const coverFormSchema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters').max(68, 'Title must be less than 68 characters'),
    duration: z.string().optional(),
});

type CoverFormValues = z.infer<typeof coverFormSchema>;

interface CoverFormProps {
    version: TourVersionModel;
    onSave: (data: Partial<TourVersionModel>) => Promise<void>;
    onCoverImageUpload: (file: File) => Promise<void>;
    isSaving?: boolean;
}

export function CoverForm({
    version,
    onSave,
    onCoverImageUpload,
    isSaving,
}: CoverFormProps) {
    const form = useForm<CoverFormValues>({
        resolver: zodResolver(coverFormSchema),
        defaultValues: {
            title: version.title || '',
            duration: version.duration || '',
        },
    });

    // Update form when version changes (e.g. initial load)
    useEffect(() => {
        form.reset({
            title: version.title || '',
            duration: version.duration || '',
        });
    }, [version, form]);

    const handleSubmit = async (data: CoverFormValues) => {
        await onSave({
            title: data.title,
            duration: data.duration,
        });
    };

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8 max-w-3xl">
                <div className="space-y-6">
                    <div className="space-y-2">
                        <h3 className="text-lg font-medium">Cover</h3>
                        <p className="text-sm text-muted-foreground">
                            This is the first thing many listeners see, so grab their attention.
                        </p>
                    </div>

                    <div className="space-y-6">
                        {/* Title */}
                        <FormField
                            control={form.control}
                            name="title"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Tour Title</FormLabel>
                                    <div className="relative">
                                        <FormControl>
                                            <Input placeholder="e.g. Paris Tours Spec" {...field} />
                                        </FormControl>
                                        <div className="absolute right-3 top-2.5 text-xs text-muted-foreground">
                                            {field.value?.length || 0}/68
                                        </div>
                                    </div>
                                    <FormDescription>
                                        Limit of 68 characters. Include important keywords like the name of the neighbourhood or major attractions.
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        {/* Duration */}
                        <FormField
                            control={form.control}
                            name="duration"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Average Duration (Minutes)</FormLabel>
                                    <Select onValueChange={field.onChange} value={field.value}>
                                        <FormControl>
                                            <SelectTrigger>
                                                <SelectValue placeholder="Select duration" />
                                            </SelectTrigger>
                                        </FormControl>
                                        <SelectContent>
                                            <SelectItem value="15">15</SelectItem>
                                            <SelectItem value="30">30</SelectItem>
                                            <SelectItem value="45">45</SelectItem>
                                            <SelectItem value="60">60</SelectItem>
                                            <SelectItem value="90">90</SelectItem>
                                            <SelectItem value="120">120</SelectItem>
                                            <SelectItem value="180">180+</SelectItem>
                                        </SelectContent>
                                    </Select>
                                    <FormDescription>
                                        How long will it take to complete the tour, on average, without stopping off anywhere?
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        {/* Cover Image */}
                        <div className="space-y-2">
                            <Label>Cover Image</Label>
                            <p className="text-[0.8rem] text-muted-foreground">
                                Displays as a banner and a square thumbnail. Dimensions: 1920px by 622px.
                            </p>
                            <div className="mt-2">
                                <CoverImageUpload
                                    imageUrl={version.coverImageUrl}
                                    onUpload={onCoverImageUpload}
                                    isUploading={false} // Todo: Pass upload state if needed
                                />
                            </div>
                        </div>
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
