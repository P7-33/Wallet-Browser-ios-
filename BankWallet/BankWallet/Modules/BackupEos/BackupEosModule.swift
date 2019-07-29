protocol IBackupEosView: class {
}

protocol IBackupEosViewDelegate {
    var account: String { get }
    var activePrivateKey: String { get }
    func didTapClose()
    func onCopyAddress()
    func onCopyPrivateKey()
}

protocol IBackupEosPresenter {
}

protocol IBackupEosRouter {
    func notifyClosed()
}

protocol IBackupEosInteractor {
    func onCopy(string: String)
}