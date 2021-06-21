import UIKit
import ThemeKit
import UniswapKit
import HUD
import RxSwift
import RxCocoa
import SectionsTableView
import ComponentKit

class SwapViewControllerNew: ThemeViewController {
    private let animationDuration: TimeInterval = 0.2
    private let disposeBag = DisposeBag()

    private let viewModel: SwapViewModelNew
    private let tableView = SectionsTableView(style: .grouped)
    private var isLoaded = false
    private var isAppeared = false

    private var dataSource: ISwapDataSource?

    init(viewModel: SwapViewModelNew) {
        self.viewModel = viewModel

        super.init()

        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "swap.title".localized

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "circle_information_24")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(onInfo))
        navigationItem.leftBarButtonItem?.tintColor = .themeJacob
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "button.close".localized, style: .plain, target: self, action: #selector(onClose))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.sectionDataSource = self
        tableView.keyboardDismissMode = .onDrag

        subscribeToViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isLoaded = true
    }

    private func subscribeToViewModel() {
        subscribe(disposeBag, viewModel.dataSourceUpdated) { [weak self] _ in
            self?.updateDataSource()
        }
        updateDataSource()
    }

    private func updateDataSource() {
        dataSource = viewModel.dataSource

        dataSource?.onReload = { [weak self] in self?.reloadTable() }
        dataSource?.onClose = { [weak self] in self?.onClose() }
        dataSource?.onOpen = { [weak self] viewController, viaPush in
            if viaPush {
                self?.navigationController?.pushViewController(viewController, animated: true)
            } else {
                self?.present(viewController, animated: true)
            }
        }
        dataSource?.onOpenSettings = { [weak self] in self?.openSettings() }

        dataSource?.viewDidLoad()

        if isLoaded {
            tableView.reload()
        } else {
            tableView.buildSections()
        }
    }

    private func openSettings() {
        guard  let viewController = SwapSettingsModule.viewController(swapDataSourceManager: viewModel.swapDataSourceManager) else {
            return
        }

        present(viewController, animated: true)
    }

    @objc func onClose() {
        dismiss(animated: true)
    }

    @objc func onInfo() {
        guard let dex = viewModel.swapDataSourceManager.dex else {
            return
        }

        let module = InfoModule.viewController(dataSource: DexInfoDataSource(dex: dex))
        present(ThemeNavigationController(rootViewController: module), animated: true)
    }

    private func reloadTable() {
        tableView.buildSections()

        guard isLoaded else {
            return
        }

        UIView.animate(withDuration: animationDuration) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

}

extension SwapViewControllerNew: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        var sections = [SectionProtocol]()

        if let dataSource = dataSource {
            sections.append(contentsOf: dataSource.buildSections())
        }

        return sections
    }

}

extension SwapViewControllerNew: IPresentDelegate {

    func show(viewController: UIViewController) {
        present(viewController, animated: true)
    }

}
