import ProjectDescription
import ProjectDescriptionHelpers
import UtilityPlugin

let project = Project.framework(
    name: "SearchInterfaces",
    featureTargets: [.staticLibrary],
    dependencies: [
        .Target.Presentation.BasePresentation.project,
        .SPM.NaverMap
    ]
)
