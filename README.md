# Forja

App iOS de foco gamificado no estilo Pomodoro. Você **liga o forno**, mantém a concentração enquanto o minério é forjado na bigorna e ganha **Barras Forjadas** para trocar por colecionáveis na loja.

Feito com **SwiftUI**, **Firebase** e animações temáticas de ferreiro.

## Funcionalidades

### Forja
- Timer configurável (15, 25, 45 ou 60 minutos) com contagem regressiva `MM:SS`
- Cena animada com fogo, faíscas, bigorna e minério evoluindo com o progresso
- **Perda de foco**: ao sair do app durante a sessão, o fogo apaga e a forja falha
- Recompensas em barras ao concluir com sucesso

### Progressão
- **Inventário** de colecionáveis adquiridos na loja
- **Loja dupla**: Oficina (Minério ganho por foco) e Tesouro (Gemas IAP)
- Pacotes sazonais (Halloween/Natal) vendidos direto, sem mexer na economia de foco
- Estatísticas de tempo de foco, forjas concluídas, falhas e sequência
- **Trilha semanal** com avatar medieval e o dia de maior foco
- Assinatura **Mestre Ferreiro** (mensal/anual) com trial de 7 dias
- Widget de streak, Live Activity e notificações de fornalha esfriando

### Perfil
- Login com **Google**, **e-mail/senha** ou modo convidado (anônimo)
- Foto de perfil (salva localmente no dispositivo)
- Metas **diária** e **semanal** com barras de progresso
- Gráfico de foco cumprido vs. não cumprido (Swift Charts)
- **Ranking global** (top 20 por tempo de foco)

### Nuvem (opcional)
- Sincronização de progresso via **Firebase Auth** + **Cloud Firestore**
- Merge inteligente entre dados locais e remotos
- Conta anônima vinculada ao criar conta (progresso preservado)

## Requisitos

| Item | Versão |
|------|--------|
| Xcode | 16+ |
| iOS | 17+ |
| Swift | 5.9+ |

O simulador funciona sem conta Apple Developer. Para dispositivo físico, configure o **Team** em *Signing & Capabilities*.

## Como executar

1. Clone o repositório
2. Abra `ForjaApp.xcodeproj` no Xcode
3. Selecione um simulador ou iPhone
4. Pressione **⌘R**

Na primeira build, o Xcode resolve as dependências via **Swift Package Manager**:
- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) (Auth, Firestore)
- [Google Sign-In iOS](https://github.com/google/GoogleSignIn-iOS)

Sem configurar o Firebase, o app funciona normalmente com persistência local (`UserDefaults`).

## Configurar Firebase

### 1. Projeto e app iOS

1. Crie um projeto em [Firebase Console](https://console.firebase.google.com)
2. Adicione um app **iOS** com bundle ID `com.lindenbergbrito.forja`
3. Baixe o `GoogleService-Info.plist`
4. Copie para `ForjaApp/GoogleService-Info.plist`  
   (use `ForjaApp/GoogleService-Info.plist.example` como referência de estrutura)

> **Importante:** não commite credenciais reais no Git. Mantenha seu `GoogleService-Info.plist` local ou use variáveis de ambiente/CI.

### 2. Authentication

Em **Authentication → Sign-in method**, ative:

- **Anonymous** (modo convidado e bootstrap inicial)
- **Email/Password**
- **Google**

### 3. Google Sign-In (URL scheme)

No `GoogleService-Info.plist`, copie o valor de `REVERSED_CLIENT_ID` e adicione em `ForjaApp/Info.plist` em `CFBundleURLTypes` → `CFBundleURLSchemes`.

Exemplo:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.SEU_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Substitua pelo `REVERSED_CLIENT_ID` do **seu** projeto Firebase.

### 4. Cloud Firestore

Crie o banco Firestore e publique regras que permitam cada usuário editar apenas o próprio documento e leitura autenticada para o ranking:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Os documentos ficam em `users/{uid}` com campos como `displayName`, `totalFocusSeconds`, `successfulSessions`, `forgedBars`, metas e colecionáveis.

Regras extras para guildas e desafios:

```javascript
match /guilds/{guildId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth != null;
}
match /challenges/{challengeId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth != null;
}
```

## Estrutura do projeto

```
ForjaApp/
├── ForjaAppApp.swift              # Entry point, Firebase e Google Sign-In
├── ContentView.swift
├── Models/
│   ├── ForgeSessionState.swift
│   ├── ShopItem.swift
│   ├── UserProgress.swift
│   ├── UserProfile.swift
│   ├── MedievalAvatar.swift
│   ├── CosmeticCatalog.swift
│   └── SocialModels.swift
├── Shared/                          # App Group + Live Activity
├── Services/
│   ├── FirebaseManager.swift      # Auth, sync, ranking
│   ├── StoreManager.swift         # StoreKit 2
│   ├── SocialService.swift        # Guildas e desafios
│   └── ...
├── Services/
│   ├── FirebaseManager.swift      # Auth, sync, ranking
│   ├── ForgeTimerService.swift
│   ├── FocusMonitor.swift
│   ├── GoogleSignInService.swift
│   ├── InventoryManager.swift
│   ├── ProfileImageStore.swift
│   └── ShopCatalog.swift
├── ViewModels/
│   ├── ForgeViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── ForgeView.swift
│   ├── InventoryView.swift
│   ├── ShopView.swift
│   ├── ProfileView.swift
│   ├── MainTabView.swift
│   └── Components/                # Animações, bigorna, gráficos, avatar
├── Extensions/
│   └── Color+Hex.swift
└── Assets.xcassets/                 # Ícone, bigorna, cores
```

## Como funciona a perda de foco

1. Inicie uma forja no simulador ou dispositivo
2. Pressione **Home** ou troque para outro app (Instagram, WhatsApp, etc.)
3. Volte ao Forja — a sessão falha e você vê o resultado **Fogo apagado!**

O tempo parcial da sessão interrompida entra nas estatísticas de foco não cumprido.

## Recompensas por duração

| Tempo | Barras forjadas |
|-------|-----------------|
| 15 min | 1 |
| 25 min | 2 |
| 45 min | 3 |
| 60 min | 4 |

## Telas

| Aba | Conteúdo |
|-----|----------|
| **Forja** | Timer, animação e início da sessão |
| **Trilha** | Mapa semanal com avatar medieval e inventário |
| **Loja** | Oficina (minério), Tesouro (gemas) e pacotes sazonais |
| **Guilda** | Clãs semanais e desafios entre amigos |
| **Perfil** | Conta, stats, metas, ranking e assinatura |

## Licença

Projeto de exemplo — COnsulte 

## Autor

Berg Limma
