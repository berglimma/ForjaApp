# Resubmit Forja 1.0 — rejeição 5.1.1(v) (15/09/2026)

## Já feito no código (build 6)

- Nova tela **Perfil → Conta e privacidade** com botão **Excluir conta permanentemente**
- Confirmação via `.alert` (funciona em iPad; substitui `confirmationDialog`)
- Contas e-mail: pede senha antes de excluir (reautenticação Firebase)
- `CURRENT_PROJECT_VERSION = 6`
- Texto de resposta: `AppStore/REVIEW-REPLY-5.1.1-v-build6.txt`

## Vídeo obrigatório (iPhone físico)

Login (conta demo) → **Perfil** → **Conta e privacidade** → **Excluir conta permanentemente** → senha → confirmar → volta ao modo convidado.

Anexar no Resolution Center **e** em App Review Information → Notas.

## Passos ASC

1. Archive + upload build **1.0 (6)**
2. Selecionar build 6 na versão 1.0
3. Atualizar notas de revisão com o caminho acima
4. Responder no Resolution Center (texto em `REVIEW-REPLY-5.1.1-v-build6.txt`) + anexar vídeo novo
5. Reenviar para revisão (app + grupo Mestre Ferreiro + Anual se aplicável)

---

# Histórico — build 5 (2.1 / 3.1.1 / 5.1.1)

- Removido voucher do paywall
- Exclusão em Perfil → Conta e dados (substituída por Conta e privacidade no build 6)

## 1) Anual IAP — captura de revisão (bloqueia “Adicionar para revisão”)

1. Abra: https://appstoreconnect.apple.com/apps/6806243098/distribution/subscriptions/6809046059
2. Em **Informações para a equipe de revisão → Captura de tela**, escolha o arquivo:

   `AppStore/screenshots/iap-review-640x920.jpg`  
   (640×920 — mínimo exigido pela Apple)

   Alternativa: `AppStore/screenshots/iap-paywall-640x920.jpg`

3. **Salvar** → **Adicionar para revisão**

## 2) Archive + upload do binário 1.0 (5)

No Xcode:

1. Product → Archive
2. Distribute App → App Store Connect → Upload
3. Em App Store Connect → versão 1.0 → selecione o build **5**

## 3) Notas de revisão + vídeo de exclusão de conta

Resolution Center:
https://appstoreconnect.apple.com/apps/6806243098/distribution/reviewsubmissions/details/38144490-326b-4ccb-8cfb-d21bc192b24d

1. **Responda à equipe de revisão de apps**
2. Cole o texto de `AppStore/REVIEW-REPLY-2.1-3.1.1-5.1.1.txt` (rascunho pode já estar preenchido)
3. **Anexar arquivo** — gravação **nova** em iPhone físico (não reuse o vídeo de 06/09; a Apple já rejeitou depois dele):

   Login (conta demo) → Perfil → Conta e dados → Excluir conta e dados → confirmar

4. Clique **Responder**

## 4) Reenviar

Pré-requisitos para habilitar **Reenviar para Revisão do app**:
- Build **1.0 (5)** selecionado (ainda está em **1.0 (4)**)
- Anual com captura → **Adicionar para revisão** (status ainda *Preparar para envio*)
- Resposta enviada no Resolution Center

Depois: **Reenviar para Revisão do app**

## Resposta pronta (inglês)

Ver `AppStore/REVIEW-REPLY-2.1-3.1.1-5.1.1.txt`
