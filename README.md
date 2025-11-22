# 🛡️ RogueASM - A Aventura em Assembly

Bem-vindo ao jogo mais “baixo nível” que você vai jogar hoje!  
Este é um **Roguelike** (jogo de exploração de masmorra) desenvolvido inteiramente em **Assembly x64 (NASM)** para Linux — porque se é pra sofrer, que seja com estilo.

Projeto desenvolvido no **Ubuntu Linux**, com muito café, paciência e alguns registradores gritando.

---

## 🎮 O Que Tem no Jogo?

* **Você é um `@`** — O herói mais valente da tabela ASCII.
* **Inimigos `E`** — Vermelhos, irritados e com tendência a te morder.
* **Combate corpo a corpo** — Chegue perto demais e veja a magia (ou a dor) acontecer.
* **Fog of War** — Você só vê o que sua tocha ilumina. O resto? Mistérios insondáveis… 👻
* **3 Fases totalmente jogáveis**:
  * **Nível 1** – Aquela introdução marota.
  * **Nível 2** – Labirinto pra testar sua sanidade.
  * **Nível 3** – Arena da Morte (10 inimigos, boa sorte).
* **Cores no terminal** — porque Assembly também pode ser bonito.

> **⚠️ Este projeto está em desenvolvimento.**  
> Novas fases e mecânicas serão adicionadas futuramente — sugestões são muito bem-vindas!

---

## ▶️ Como Rodar (Guia Definitivo do Jogador)

### 1. Pré-requisitos

Certifique-se de estar no **Linux** (Ubuntu recomendado).  
Instale as ferramentas necessárias:

```bash
sudo apt update
sudo apt install nasm make binutils
```

*(Se pedir senha, digite e aperte Enter. Mesmo sem aparecer nada... é normal. O Linux é tímido.)*

### 2. O Comando Mágico™

Copie e cole isso no terminal para compilar, configurar o teclado e rodar o jogo:

```bash
make clean && make && stty -icanon -echo && ./game
```

O que acontece por trás dos panos:

1. Limpa arquivos antigos (`make clean`)  
2. Compila tudo (`make`)  
3. Deixa o teclado no “Modo Gamer” (sem precisar apertar Enter)  
4. Executa o jogo 🎮

---

## 🕹️ Como Jogar

### Controles
* **Mover**: Setas ⬆️⬇️⬅️➡️ ou **WASD**
* **Objetivo**: Encontrar a escada **`>`** e avançar de fase.

### Elementos do Jogo
* `@` **(Amarelo)** — Você.
* `E` **(Vermelho)** — Inimigo (não é seu amigo).
* `#` **(Azul)** — Parede (não atravessa, infelizmente).
* `+` **(Verde)** — Poção (cura instantânea).
* `>` **(Roxo)** — Saída da fase.

### Regras
1. Se sua **HP** chegar a 0 → *Game Over*.
2. Inimigos mortos renascem em outro local (vida dura a deles).
3. Vença as 3 fases para ganhar a tela de **VITÓRIA** 🏆.

---

## 🆘 Terminal Ficou Maluco?

Se o jogo fechar errado e seu terminal parar de mostrar o que você digita, respire fundo… e digite o seguinte (mesmo às cegas):

```bash
reset
```

Seu terminal volta ao normal na hora.

---

## 📂 Estrutura do Projeto

O código foi divido em módulos para manter tudo limpo e organizado (na medida do possível para Assembly):

* `src/main.asm` — Ponto inicial da aventura.
* `src/engine.asm` — Variáveis globais e gerenciamento da memória.
* `src/mechanics.asm` — Física, colisões e carregamento dos mapas.
* `src/ai.asm` — Inteligência dos inimigos.
* `src/display.asm` — Renderização, cores, fog of war e HUD.
* `src/input.asm` — Leitura do teclado.

---

## ✍️ Autoria

Projeto desenvolvido por **Davi Afonso**.  
Se quiser sugerir melhorias, otimizações, novas features ou só reclamar sobre Assembly, fique à vontade. Toda sugestão é bem-vinda!

*Feito com ❤️, dedicação e alguns bytes de sanidade restantes.*
