//
//  LegalViews.swift
//  ForjaApp
//

import SwiftUI

enum ForjaLegal {
    static let appleStandardEULA = URL(
        string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    )!

    static let privacyPolicyURL = URL(
        string: "https://berglimma.github.io/forja-legal/privacidade.html"
    )!

    static let privacyPolicy = """
    Política de privacidade — Forja

    Última atualização: 28 de agosto de 2026.

    O Forja é um app de foco. Coletamos só o necessário para conta, progresso e compras.

    1. Dados que tratamos
    • Conta: nome de ferreiro, e-mail (se você cadastrar ou entrar com Google) e identificador da Apple (se entrar com Apple).
    • Progresso: tempo de foco, minério, gemas, colecionáveis, avatar e metas — salvos no aparelho e, se você estiver logado, no Firebase (Firestore).
    • Foto de perfil: fica só neste aparelho, se você escolher câmera ou galeria.
    • Compras: assinatura, gemas e pacotes são processados pela Apple. Não recebemos o número do seu cartão.

    2. Para que usamos
    • Fazer login, sincronizar o ofício entre aparelhos e mostrar o ranking.
    • Entregar a assinatura Mestre Ferreiro e itens da loja.
    • Enviar lembretes locais de foco, se você ligar as notificações.

    3. O que não fazemos
    • Não vendemos seus dados.
    • Não usamos publicidade de terceiros nem rastreamento entre apps (App Tracking Transparency não se aplica).

    4. Conservação e exclusão
    Dados locais ficam no aparelho até você apagar o app ou excluir a conta. Na nuvem, o documento do usuário é removido em Perfil → Conta e privacidade → Excluir conta permanentemente. A Apple guarda o histórico de compras segundo as regras da App Store.

    5. Terceiros
    • Firebase (Google): autenticação e Firestore.
    • Google Sign-In, se você escolher esse login.
    • Apple: Sign in with Apple, StoreKit e notificações locais no sistema.

    6. Crianças
    O Forja não é dirigido a menores de 13 anos.

    7. Contato
    Dúvidas sobre privacidade: use o e-mail de suporte informado na ficha da App Store.
    """
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text(ForjaLegal.privacyPolicy)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color(hex: "#0D1117") ?? .black)
        .navigationTitle("Privacidade")
        .navigationBarTitleDisplayMode(.inline)
    }
}
