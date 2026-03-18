import 'dart:io';
import 'dart:math';

class Ponto {
  int x; //linha
  int y; //coluna
  bool atingido = false; //ve se ja foi atacado
  bool temnavio = false;

  Ponto(this.x, this.y, {this.atingido = false});
  
  void marcarcomoatingido(){
    atingido = true;
  }

  void temnaviolocal(){
    temnavio = true;
  }

  @override
String toString() {
    if (atingido) {
      return temnavio ? "X" : "O"; // X explosão, O água
    }
    if (temnavio) {
      return "N"; //Meu navio
    }
    return "~";
  }
}


  //TABULEIROS
void main(){
  //main executa o jg
  int tamanhoGeral = 16;

  var meuTabuleiro = gerarTabuleiro(tamanhoGeral);
  var tabuleiroMaq = gerarTabuleiro(tamanhoGeral);
  var gerador = Random();

  //Maq posicionar
  bool posicionado = false;

  while(!posicionado){ // loop 
    int linhaSorteada = gerador.nextInt(tamanhoGeral);// sorteia linha de 0 a 15
    int colunaSorteada = gerador.nextInt(tamanhoGeral);
    String direcaoSorteada = gerador.nextBool() ? "H" : "V";
  // se esta disponivel para colocar o navio
    if (podePosicionar(tabuleiroMaq, linhaSorteada, colunaSorteada, direcaoSorteada, tamanhoGeral)){
      colocarNavio(tabuleiroMaq, linhaSorteada, colunaSorteada, direcaoSorteada);
      posicionado = true;
    }
  }
  print("Máquina deu bom");

  //meu posicionamento
  bool meuNavioPosicionado = false;

  while(!meuNavioPosicionado){
    print("POSICIONE SEU NAVIO");
    stdout.write("Digite a linha (0-15): ");
    int LUser = int.parse(stdin.readLineSync()!); //! = n envia valor vazio
    stdout.write("Digite a coluna (0-15): ");
    int CUser = int.parse(stdin.readLineSync()!);

    String DUser = "";
    //verificação
    while (DUser != "H" && DUser != "V"){
      stdout.write("Digite a direção H(Horizontal) ou V(Vertical): ");
      DUser = stdin.readLineSync()!.toUpperCase().trim();
      if (DUser != "H" && DUser != "V"){
        print("Escreva somente H ou V");
      }
    }

    if (podePosicionar(meuTabuleiro, LUser, CUser, DUser, tamanhoGeral)){
      colocarNavio(meuTabuleiro, LUser, CUser, DUser);
      meuNavioPosicionado = true;
      print("Navio posicionado!");
    } else {
      print("Erro! Navio não cabe aqui.");
    }
  }
  //loop do jg
  int acertos = 0;
  int acertosMaq = 0;

  print("Começou a batalha!");

  while (acertos < 4 && acertosMaq < 4){
    imprimirTabuleiros(meuTabuleiro, tabuleiroMaq);

    int? lTiro;
    while(lTiro == null || lTiro <= 0 || lTiro >= 15){
      stdout.write("Onde quer atacar? Linha (0-15): ");
      String entrada = stdin.readLineSync()!;
      lTiro = int.tryParse(entrada);

      if (lTiro == null || lTiro < 0 || lTiro > 15){
        print("Erro! numero de 0 a 15");
      }
    }
    int? cTiro;
    while (cTiro == null || cTiro < 0 || cTiro > 15) {
      stdout.write("Agora a Coluna (0-15): ");
      String entrada = stdin.readLineSync()!;
      cTiro = int.tryParse(entrada);

      if (cTiro == null || cTiro < 0 || cTiro > 15) {
        print("Erro! numero de 0 e 15");
      }
    }

    bool acertou = realizarAtaque(tabuleiroMaq, lTiro, cTiro);
    if(acertou){
      acertos++;
    }
    if (acertos == 4) break;
    //ataqueMaq
    print("Maq vai atacar");
    bool maqTentando = true;

    while(maqTentando){
      int linhaMaq = Random().nextInt(16);
      int colunaMaq = Random().nextInt(16);

      //ve se ja n atirou ali antes
      if(!meuTabuleiro[linhaMaq] [colunaMaq].atingido){
        bool acertouVoce = realizarAtaque(meuTabuleiro, linhaMaq, colunaMaq);

        if (acertouVoce) {
          print("A máquina acertou em ${linhaMaq}, ${colunaMaq}");
          acertosMaq++;
        } else {
          print("A máquina errou em ${linhaMaq}, ${colunaMaq}");
        }
        maqTentando = false;
      }
    }
    print("\n VOCÊ ${acertos}/4   Máquina ${acertosMaq}/4");
    print("Pressione ENTER.");
    stdin.readLineSync();
  }
  if(acertos == 4){
    print("Acabou! Você ganhou");
  } else{
    print("Você perdeu!");
  }
}

  //imprimir tabuleiros
  void imprimirTabuleiros(List<List<Ponto>> meuTab, List<List<Ponto>> tabMaq) {
  String header = "   0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15";
  print("\n    MEU TABULEIRO                                          TABULEIRO MÁQUINA");
  print("$header      $header");
    for (int l = 0; l < meuTab.length; l++) {
      String linhaMeu = l.toString().padLeft(2, ' ') + "  ";
      for (var ponto in meuTab[l]) {
        linhaMeu += "${ponto.toString()}  "; //puxa do override
      }
      // Espaço
      linhaMeu += "   ";

      String linhaMaq = l.toString().padLeft(2, ' ') + "  ";
      for (var ponto in tabMaq[l]) {
        if (!ponto.atingido) {
        linhaMaq += "?  "; // Esconde
      } else {
        linhaMaq += "${ponto.toString()}  "; // Mostra X ou O
      }
    }   
      print(linhaMeu + linhaMaq);
    }
  }


  //ataque

  bool realizarAtaque(List<List<Ponto>> tab, int l, int c){
    var alvo = tab[l][c];
    //chama o metodo que muda boolean atingido para true
    alvo.marcarcomoatingido();
    return alvo.temnavio;
  }

  List<List<Ponto>> gerarTabuleiro(int tamanho) {
    List<List<Ponto>> tabuleiro = []; //lista vazia p add as linha

    for(int l = 0; l < 16; l++){ //linhas
      List<Ponto> linha = []; // armazena os estados de cada linha
      for(int c = 0; c < 16; c++){ //colunas
        linha.add(Ponto(l,c));
      }
      tabuleiro.add(linha);
    }
    return tabuleiro;
    }

  //NAVIOS
  bool podePosicionar(List<List<Ponto>> tab, int l, int c, String direcao, int tamanho) {
    if (direcao == "H") {
      if (c + 3 >= tamanho){ // se a coluna final estoura o tabuleiro
        return false;
      }
      for (int i = 0; i < 4; i++){ // ve se ta ocupado
        if (tab[l][c + i].temnavio){
          return false;
        }
      }
    } else if (direcao == "V"){// se a linha final estoura o tabuleiro
      if (l + 3 >= tamanho){
        return false;
      }
      for (int i = 0; i < 4; i++){
        if (tab[l + i][c].temnavio){
          return false;
        }
      }
    }
    return true;
  }

void colocarNavio(List<List<Ponto>> tab, int l, int c, String direcao){
  for(int i = 0; i < 4; i++){
    if(direcao == "H"){
      tab[l][c + i].temnaviolocal(); // marca 4 na horizontal
    } else if (direcao == "V") {
      tab[l + i][c].temnaviolocal(); // marca 4 na vertical
    }
  }
}
