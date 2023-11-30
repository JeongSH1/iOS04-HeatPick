//
//  SearchBuilder.swift
//  SearchImplementations
//
//  Created by 이준복 on 2023/11/13.
//  Copyright © 2023 codesquad. All rights reserved.
//

import ModernRIBs
import HomeInterfaces
import SearchInterfaces
import StoryInterfaces
import DomainInterfaces

public protocol SearchDependency: Dependency {
    var searchUseCase: SearchUseCaseInterface { get }
    var storyEditorBuilder: StoryEditorBuildable { get }
    var storyDeatilBuilder: StoryDetailBuildable { get }
}

final class SearchComponent: Component<SearchDependency>,
                             SearchInteractorDependency,
                             SearchCurrentLocationStoryListDependency,
                             SearchResultDependency,
                             SearchStorySeeAllDependency {
    
    var searchUseCase: SearchUseCaseInterface { dependency.searchUseCase }
    var searchCurrentLocationStoryListUseCase: SearchCurrentLocationStoryListUseCaseInterface { dependency.searchUseCase }
    var searchResultUseCase: SearchResultUseCaseInterface { dependency.searchUseCase }
    var searchMapUseCase: SearchMapUseCaseInterface { dependency.searchUseCase }
    var storyEditorBuilder: StoryEditorBuildable { dependency.storyEditorBuilder }
    var storyDeatilBuilder: StoryDetailBuildable { dependency.storyDeatilBuilder }
    var searchStorySeeAllUseCase: SearchStorySeeAllUseCaseInterface { dependency.searchUseCase }
    
}

final class SearchRouterComponent: SearchRouterDependency {
    
    let searchCurrentLocationBuilder: SearchCurrentLocationStoryListBuildable
    let searchResultBuilder: SearchResultBuildable
    let storyEditorBuilder: StoryEditorBuildable
    let storyDeatilBuilder: StoryDetailBuildable
    let searchStorySeeAllBuilder: SearchStorySeeAllBuildable
    
    init(component: SearchComponent) {
        self.searchCurrentLocationBuilder = SearchCurrentLocationStoryListBuilder(dependency: component)
        self.searchResultBuilder = SearchResultBuilder(dependency: component)
        self.storyEditorBuilder = component.storyEditorBuilder
        self.storyDeatilBuilder = component.storyDeatilBuilder
        self.searchStorySeeAllBuilder = SearchStorySeeAllBuilder(dependency: component)
    }
    
}

public final class SearchBuilder: Builder<SearchDependency>, SearchBuildable {
    
    public override init(dependency: SearchDependency) {
        super.init(dependency: dependency)
    }
    
    public func build(withListener listener: SearchListener) -> ViewableRouting {
        let component = SearchComponent(dependency: dependency)
        let routerComponent = SearchRouterComponent(component: component)
        let viewController = SearchViewController()
        let interactor = SearchInteractor(presenter: viewController, dependency: component)
        interactor.listener = listener
        return SearchRouter(
            interactor: interactor,
            viewController: viewController,
            dependency: routerComponent
        )
    }
}
