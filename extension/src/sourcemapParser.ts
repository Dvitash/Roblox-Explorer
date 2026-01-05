import * as vscode from "vscode";

interface SourcemapNode {
    name: string;
    className: string;
    children?: SourcemapNode[];
    filePaths?: string[];
}

export class SourcemapParser {
    private sourcemap: { node: SourcemapNode; baseUri: vscode.Uri } | null = null;

    constructor(private workspaceRoot: vscode.Uri) { }

    async loadSourcemaps(): Promise<void> {
        const config = vscode.workspace.getConfiguration('verde');
        const sourcemapPath = config.get<string>('sourcemapPath', 'sourcemap.json');

        try {
            const uri = vscode.Uri.joinPath(this.workspaceRoot, sourcemapPath);
            const content = await vscode.workspace.fs.readFile(uri);
            const sourcemap = JSON.parse(content.toString());
            const baseUri = vscode.Uri.joinPath(uri, '..');
            this.sourcemap = { node: sourcemap, baseUri };
            console.log(`Loaded sourcemap from ${sourcemapPath}`);
        } catch (error) {
            console.warn(`Failed to load sourcemap at ${sourcemapPath}:`, error);
            this.sourcemap = null;
        }
    }

    findFilePath(instancePath: string[]): vscode.Uri | null {
        if (!this.sourcemap) {
            return null;
        }

        const filePath = this.searchNode(this.sourcemap.node, instancePath, 0);
        if (filePath) {
            return vscode.Uri.joinPath(this.sourcemap.baseUri, filePath);
        }
        return null;
    }

    private searchNode(node: SourcemapNode, path: string[], index: number): string | null {
        if (index >= path.length) {
            return node.filePaths?.[0] || null;
        }

        if (!node.children) {
            return null;
        }

        for (const child of node.children) {
            if (child.name === path[index]) {
                return this.searchNode(child, path, index + 1);
            }
        }

        return null;
    }
}
