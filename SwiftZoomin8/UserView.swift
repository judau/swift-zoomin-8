import Foundation
import SwiftUI

@MainActor struct UserView: View {
    @StateObject private var uvs: UserViewState
    init(id: User.ID) {
        self._uvs = StateObject(wrappedValue: UserViewState(id: id))
    }
    var body: some View {
        VStack {
            Group {
                if let iconImage = uvs.iconImage {
                    Image(uiImage: iconImage)
                            .resizable()
                } else {
                    Color.clear
                }
            }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            .overlay(Circle().stroke(Color(uiColor: .systemGray3), lineWidth: 4))
            if let name = uvs.user?.name {
                Text(name)
            }
            Spacer()
        }
        .task {
            await uvs.loadUser()
        }
    }
}