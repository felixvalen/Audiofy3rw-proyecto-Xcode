import CarPlay

final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ scene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        Task { @MainActor in AudioManager.shared.configure() }

        // Sustituir por la biblioteca real
        let tracks: [Track] = []
        let items: [CPListItem] = tracks.enumerated().map { i, t in
            let item = CPListItem(text: t.title, detailText: t.artist)
            item.handler = { _, completion in
                Task { @MainActor in AudioManager.shared.setQueue(tracks, startAt: i) }
                completion()
            }
            return item
        }

        let library = CPListTemplate(title: "Biblioteca", sections: [CPListSection(items: items)])
        library.tabTitle = "Biblioteca"
        library.tabImage = UIImage(systemName: "music.note.list")

        let root = CPTabBarTemplate(templates: [library, CPNowPlayingTemplate.shared])
        interfaceController.setRootTemplate(root, animated: true, completion: nil)
    }

    func templateApplicationScene(_ scene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}
