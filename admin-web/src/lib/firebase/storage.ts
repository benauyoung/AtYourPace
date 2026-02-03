import {
    deleteObject,
    getDownloadURL,
    listAll,
    ref,
    uploadBytes,
} from 'firebase/storage';
import { storage } from './config';

export interface StorageFile {
    name: string;
    fullPath: string;
    url: string;
}

/**
 * Upload a file to Firebase Storage
 * @param file The file object to upload
 * @param path The path in storage (e.g., 'tours/123/image.jpg')
 * @returns The download URL of the uploaded file
 */
export async function uploadFile(file: File, path: string): Promise<string> {
    const storageRef = ref(storage, path);
    await uploadBytes(storageRef, file);
    return getDownloadURL(storageRef);
}

/**
 * Delete a file from Firebase Storage
 * @param path The full path of the file to delete
 */
export async function deleteFile(path: string): Promise<void> {
    const storageRef = ref(storage, path);
    await deleteObject(storageRef);
}

/**
 * List all files in a specific directory
 * @param path The directory path to list files from
 * @returns Array of StorageFile objects
 */
export async function listFiles(path: string): Promise<StorageFile[]> {
    const listRef = ref(storage, path);
    const res = await listAll(listRef);

    const filePromises = res.items.map(async (itemRef) => {
        const url = await getDownloadURL(itemRef);
        return {
            name: itemRef.name,
            fullPath: itemRef.fullPath,
            url,
        };
    });

    return Promise.all(filePromises);
}
