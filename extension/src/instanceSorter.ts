export interface SortableNode {
    id: string;
    name: string;
    className: string;
}

export class InstanceSorter {
    private getServiceOrder(className: string): number {
        const serviceOrder = [
            "Workspace",
            "Players",
            "Lighting",
            "MaterialService",
            "ReplicatedFirst",
            "ReplicatedStorage",
            "ServerScriptService",
            "ServerStorage",
            "StarterGui",
            "StarterPack",
            "StarterPlayer",
            "Teams",
            "SoundService",
            "TextChatService",
            "TestService",
            "LocalizationService",
            "VoiceChatService",
            "VRService"
        ];

        const index = serviceOrder.indexOf(className);
        return index === -1 ? -1 : index;
    }

    public sortNodes(nodes: SortableNode[]): SortableNode[] {
        return nodes.sort((a, b) => {
            const aServiceOrder = this.getServiceOrder(a.className);
            const bServiceOrder = this.getServiceOrder(b.className);
            const aIsService = aServiceOrder !== -1;
            const bIsService = bServiceOrder !== -1;

            const aIsSpecial = a.className === "Camera" || a.className === "Terrain";
            const bIsSpecial = b.className === "Camera" || b.className === "Terrain";

            const aIsFolder = a.className === "Folder";
            const bIsFolder = b.className === "Folder";

            const aIsSpawnLocation = a.className === "SpawnLocation";
            const bIsSpawnLocation = b.className === "SpawnLocation";

            if (aIsService && bIsService) {
                return aServiceOrder - bServiceOrder;
            }
            if (aIsService && !bIsService) {
                return -1;
            }
            if (!aIsService && bIsService) {
                return 1;
            }

            if (aIsSpecial && bIsSpecial) {
                if (a.className === "Camera") {
                    return -1;
                }
                if (b.className === "Camera") {
                    return 1;
                }
                return 0;
            }
            if (aIsSpecial && !bIsSpecial) {
                return -1;
            }
            if (!aIsSpecial && bIsSpecial) {
                return 1;
            }

            if (aIsFolder && !bIsFolder) {
                return -1;
            }
            if (!aIsFolder && bIsFolder) {
                return 1;
            }

            if (aIsSpawnLocation && !bIsSpawnLocation) {
                return -1;
            }
            if (!aIsSpawnLocation && bIsSpawnLocation) {
                return 1;
            }

            return a.name.localeCompare(b.name);
        });
    }
}
