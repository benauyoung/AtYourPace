'use client';

import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
// import { LocationPicker } from './location-picker'; // Or a simplified city search

const startTourSchema = z.object({
    title: z.string().min(3, 'Title is required').max(100),
    destination: z.string().min(1, 'Destination is required'), // Simplified for now, eventually a geocoding search
    price: z.string().optional(), // In the mockup it's "9.99", dealing with numbers as strings for select initially
    transportMode: z.enum(['walking', 'driving']),
});

type StartTourValues = z.infer<typeof startTourSchema>;

interface StartTourModalProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    onCreate: (data: StartTourValues) => Promise<void>;
}

export function StartTourModal({ open, onOpenChange, onCreate }: StartTourModalProps) {
    const [isCreating, setIsCreating] = useState(false);

    const form = useForm<StartTourValues>({
        resolver: zodResolver(startTourSchema),
        defaultValues: {
            title: '',
            destination: '',
            price: 'free', // Default to free or a tier
            transportMode: 'walking',
        },
    });

    const handleSubmit = async (data: StartTourValues) => {
        setIsCreating(true);
        try {
            await onCreate(data);
            onOpenChange(false);
        } catch (e) {
            console.error(e);
        } finally {
            setIsCreating(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[500px]">
                <DialogHeader>
                    <DialogTitle>Start a new tour</DialogTitle>
                    <DialogDescription>
                        You can change the name, city and price before you publish your tour.
                    </DialogDescription>
                </DialogHeader>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
                        <FormField
                            control={form.control}
                            name="title"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Tour title</FormLabel>
                                    <FormControl>
                                        <Input placeholder="e.g. Classic Sights and Hidden Histories" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="destination"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Destination</FormLabel>
                                    <FormControl>
                                        <Input placeholder="Type the name of the city, town or region" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="price"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Price (USD)</FormLabel>
                                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Price" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="free">Free</SelectItem>
                                                <SelectItem value="4.99">4.99</SelectItem>
                                                <SelectItem value="9.99">9.99</SelectItem>
                                                <SelectItem value="14.99">14.99</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="transportMode"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Mode of Transport</FormLabel>
                                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Mode" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="walking">Walk</SelectItem>
                                                <SelectItem value="driving">Drive</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <DialogFooter className="mt-6">
                            <Button type="submit" className="w-full bg-red-600 hover:bg-red-700 text-white" disabled={isCreating}>
                                {isCreating && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                Create Tour
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    );
}
