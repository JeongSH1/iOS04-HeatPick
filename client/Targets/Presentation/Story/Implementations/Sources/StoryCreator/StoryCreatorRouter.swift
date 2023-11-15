//
//  StoryCreatorRouter.swift
//  StoryImplementations
//
//  Created by jungmin lim on 11/15/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import ModernRIBs

import CoreKit

public protocol StoryCreatorInteractable: Interactable,
                                          StoryEditorListener {
    var router: StoryCreatorRouting? { get set }
    var listener: StoryCreatorListener? { get set }
}

public protocol StoryCreatorViewControllable: ViewControllable {}

public protocol StoryCreatorRouterDependency {
    var storyEditorBuilder: StoryEditorBuildable { get }
}

final class StoryCreatorRouter: ViewableRouter<StoryCreatorInteractable, StoryCreatorViewControllable>, StoryCreatorRouting {

    private let storyEditorBuilder: StoryEditorBuildable
    private var storyEditorRouter: Routing?
    
    init(interactor: StoryCreatorInteractable,
         viewController: StoryCreatorViewControllable,
         dependency: StoryCreatorRouterDependency
    ) {
        self.storyEditorBuilder = dependency.storyEditorBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachStoryEditor() {
        guard storyEditorRouter == nil else { return }
        let storyEditorRouting = storyEditorBuilder.build(withListener: interactor)
        self.storyEditorRouter = storyEditorRouting
        attachChild(storyEditorRouting)
        let storyEditorViewController = NavigationControllable(viewControllable: storyEditorRouting.viewControllable)
        viewController.present(storyEditorViewController, animated: true, isFullScreen: true)
    }
    
    func detachStoryEditor() {
        guard let router = storyEditorRouter else { return }
        detachChild(router)
        self.storyEditorRouter = nil
        viewControllable.dismiss(animated: true)
    }
    
}
