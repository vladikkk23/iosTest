//

import Foundation

// MARK: - List Model
struct ListModel: Identifiable, Equatable {
    let imageName: String
    let title: String
    let id: UUID = UUID()
}
