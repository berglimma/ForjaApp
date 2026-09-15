//
//  AccountSettingsView.swift
//  ForjaApp
//

import SwiftUI

struct AccountSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var firebase: FirebaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                if let email = viewModel.currentUser?.email {
                    LabeledContent("E-mail", value: email)
                }
                LabeledContent("Nome", value: viewModel.progress.displayName)
                LabeledContent("Provedor", value: providerLabel)
            } header: {
                Text("Sua conta")
            }

            Section {
                Text("A exclusão é permanente: remove login, progresso na nuvem e ranking. Compras da App Store permanecem na sua conta Apple — use Restaurar compras se criar outra conta.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    if viewModel.currentUser?.provider == .email {
                        viewModel.showDeleteReauth = true
                    } else {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Label("Excluir conta permanentemente", systemImage: "trash.fill")
                        .font(.body.weight(.semibold))
                }
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("account.delete.button")
                .accessibilityLabel("Excluir conta permanentemente")
            } header: {
                Text("Excluir conta")
            } footer: {
                Text("Account deletion: Perfil → Conta e privacidade → Excluir conta permanentemente.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    Task { await viewModel.signOut() }
                } label: {
                    Label("Sair da conta", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Conta e privacidade")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Excluir conta permanentemente?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir conta e dados", role: .destructive) {
                Task { await viewModel.deleteAccount(reauthPassword: nil) }
            }
        } message: {
            Text("Esta ação não pode ser desfeita. Todos os dados da conta serão apagados.")
        }
        .sheet(isPresented: $viewModel.showDeleteReauth) {
            deleteReauthSheet
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var providerLabel: String {
        switch viewModel.currentUser?.provider {
        case .google: return "Google"
        case .apple: return "Apple"
        case .email: return "E-mail e senha"
        default: return "Conta"
        }
    }

    private var deleteReauthSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Por segurança, confirme sua senha para excluir a conta.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    SecureField("Senha da conta", text: $viewModel.deleteReauthPassword)
                        .textContentType(.password)
                }

                if let message = viewModel.authMessage {
                    Section {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteAccount(reauthPassword: viewModel.deleteReauthPassword)
                        }
                    } label: {
                        Text("Confirmar exclusão")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.deleteReauthPassword.count < 6 || viewModel.isLoading)
                }
            }
            .navigationTitle("Confirmar exclusão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.showDeleteReauth = false
                        viewModel.deleteReauthPassword = ""
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
