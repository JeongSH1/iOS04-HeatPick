import ProjectDescription
import ProjectDescriptionHelpers
import UtilityPlugin

let project = Project.framework(
    name: "AuthInterfaces",
    featureTargets: [.staticLibrary],
    dependencies: [
        .Target.Presentation.BasePresentation.project,
        .SPM.NaverLogin
    ]
)
