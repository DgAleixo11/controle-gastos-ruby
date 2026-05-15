# ============================================================
# CONTROLE DE GASTOS EM RUBY
# Projeto de terminal para controle financeiro pessoal.
#
# O sistema permite:
# - Cadastrar receitas
# - Cadastrar despesas
# - Listar transações
# - Filtrar por categoria
# - Filtrar por mês
# - Gerar relatórios
# - Editar e excluir transações
# - Exportar dados para CSV
#
# Bibliotecas usadas:
# json      -> salvar e ler dados em arquivo .json
# date      -> validar e ordenar datas
# fileutils -> criar pastas/arquivos automaticamente
# csv       -> exportar dados para planilha .csv
# ============================================================

require "json"
require "date"
require "fileutils"
require "csv"

# Caminho da pasta onde ficam os dados.
PASTA_DADOS = "data"

# Caminho da pasta onde ficarão os arquivos exportados.
PASTA_EXPORTS = "exports"

# Caminho do arquivo JSON principal.
ARQUIVO_JSON = "#{PASTA_DADOS}/transacoes.json"

# ------------------------------------------------------------
# PREPARAÇÃO DO PROJETO
# ------------------------------------------------------------

# Este método garante que as pastas e o arquivo JSON existam.
# Assim, se alguém baixar o projeto do GitHub e rodar,
# o sistema consegue se preparar sozinho.
def preparar_ambiente
  FileUtils.mkdir_p(PASTA_DADOS)
  FileUtils.mkdir_p(PASTA_EXPORTS)

  unless File.exist?(ARQUIVO_JSON)
    File.write(ARQUIVO_JSON, JSON.pretty_generate([]))
  end
end

# ------------------------------------------------------------
# MÉTODOS DE ARQUIVO
# ------------------------------------------------------------

# Carrega as transações salvas no arquivo JSON.
def carregar_transacoes
  preparar_ambiente

  conteudo = File.read(ARQUIVO_JSON)

  # Se o arquivo estiver vazio, retornamos um array vazio.
  return [] if conteudo.strip.empty?

  JSON.parse(conteudo)
rescue JSON::ParserError
  # Se o JSON estiver quebrado, evitamos que o app trave.
  puts "Erro ao ler o arquivo JSON. Verifique data/transacoes.json."
  []
end

# Salva as transações no arquivo JSON.
def salvar_transacoes(transacoes)
  preparar_ambiente
  File.write(ARQUIVO_JSON, JSON.pretty_generate(transacoes))
end

# ------------------------------------------------------------
# MÉTODOS DE FORMATAÇÃO
# ------------------------------------------------------------

# Formata valores com duas casas decimais.
def formatar_moeda(valor)
  "R$ #{format('%.2f', valor)}"
end

# Converte texto no formato DD/MM/AAAA para objeto Date.
def converter_para_data(data)
  Date.strptime(data, "%d/%m/%Y")
end

# Imprime uma transação de forma padronizada.
def imprimir_transacao(transacao, index = nil)
  prefixo = index ? "#{index + 1}. " : ""

  puts "#{prefixo}#{transacao["tipo"].capitalize} - #{transacao["descricao"]}"
  puts "   Valor: #{formatar_moeda(transacao["valor"])}"
  puts "   Categoria: #{transacao["categoria"]}"
  puts "   Data: #{transacao["data"]}"
  puts "--------------------------"
end

# ------------------------------------------------------------
# VALIDAÇÕES
# ------------------------------------------------------------

# Verifica se uma data é real e está no formato correto.
def data_valida?(data)
  formato_correto = data.match?(/^\d{2}\/\d{2}\/\d{4}$/)

  return false unless formato_correto

  begin
    Date.strptime(data, "%d/%m/%Y")
    true
  rescue ArgumentError
    false
  end
end

# Verifica se mês/ano está no formato MM/AAAA.
def mes_ano_valido?(mes_ano)
  formato_correto = mes_ano.match?(/^\d{2}\/\d{4}$/)

  return false unless formato_correto

  partes = mes_ano.split("/")
  mes = partes[0].to_i
  ano = partes[1].to_i

  mes >= 1 && mes <= 12 && ano > 0
end

# ------------------------------------------------------------
# ENTRADAS DO USUÁRIO
# ------------------------------------------------------------

# Pede um texto obrigatório.
def pedir_texto_obrigatorio(mensagem)
  loop do
    print mensagem
    texto = gets.chomp.strip

    if texto.empty?
      puts "Esse campo não pode ficar vazio."
    else
      return texto
    end
  end
end

# Pede um valor maior que zero.
def pedir_valor
  loop do
    print "Valor: R$ "
    entrada = gets.chomp.strip.gsub(",", ".")
    valor = entrada.to_f

    if valor > 0
      return valor
    else
      puts "Digite um valor maior que zero."
    end
  end
end

# Pede uma data válida.
def pedir_data
  loop do
    print "Data, exemplo 15/05/2026: "
    data = gets.chomp.strip

    if data_valida?(data)
      return data
    else
      puts "Data inválida. Use uma data real no formato DD/MM/AAAA."
    end
  end
end

# Pede mês e ano válidos.
def pedir_mes_ano
  loop do
    print "Digite o mês e ano, exemplo 05/2026: "
    mes_ano = gets.chomp.strip

    if mes_ano_valido?(mes_ano)
      return mes_ano
    else
      puts "Mês/ano inválido. Use o formato MM/AAAA."
    end
  end
end

# ------------------------------------------------------------
# MENU
# ------------------------------------------------------------

def mostrar_menu
  puts
  puts "======================================"
  puts "        CONTROLE DE GASTOS RUBY"
  puts "======================================"
  puts "1  - Adicionar receita"
  puts "2  - Adicionar despesa"
  puts "3  - Listar transações"
  puts "4  - Ver saldo geral"
  puts "5  - Filtrar por categoria"
  puts "6  - Excluir transação"
  puts "7  - Filtrar por mês"
  puts "8  - Relatório por categoria"
  puts "9  - Relatório mensal por categoria"
  puts "10 - Listar transações por data"
  puts "11 - Editar transação"
  puts "12 - Buscar por descrição"
  puts "13 - Exportar para CSV"
  puts "0  - Sair"
  print "Escolha uma opção: "
end

# ------------------------------------------------------------
# CADASTRAR TRANSAÇÃO
# ------------------------------------------------------------

def adicionar_transacao(tipo)
  transacoes = carregar_transacoes

  descricao = pedir_texto_obrigatorio("Descrição: ")
  valor = pedir_valor
  categoria = pedir_texto_obrigatorio("Categoria: ")
  data = pedir_data

  transacao = {
    "tipo" => tipo,
    "descricao" => descricao,
    "valor" => valor,
    "categoria" => categoria,
    "data" => data
  }

  transacoes << transacao
  salvar_transacoes(transacoes)

  puts "#{tipo.capitalize} cadastrada com sucesso!"
end

# ------------------------------------------------------------
# LISTAR TRANSAÇÕES
# ------------------------------------------------------------

def listar_transacoes
  transacoes = carregar_transacoes

  if transacoes.empty?
    puts "Nenhuma transação cadastrada."
    return
  end

  puts
  puts "===== TRANSAÇÕES CADASTRADAS ====="

  transacoes.each_with_index do |transacao, index|
    imprimir_transacao(transacao, index)
  end
end

# ------------------------------------------------------------
# VER SALDO GERAL
# ------------------------------------------------------------

def ver_saldo
  transacoes = carregar_transacoes

  receitas = transacoes
    .select { |transacao| transacao["tipo"] == "receita" }
    .sum { |transacao| transacao["valor"] }

  despesas = transacoes
    .select { |transacao| transacao["tipo"] == "despesa" }
    .sum { |transacao| transacao["valor"] }

  saldo = receitas - despesas

  puts
  puts "===== RESUMO GERAL ====="
  puts "Receitas: #{formatar_moeda(receitas)}"
  puts "Despesas: #{formatar_moeda(despesas)}"
  puts "Saldo: #{formatar_moeda(saldo)}"
end

# ------------------------------------------------------------
# FILTRAR POR CATEGORIA
# ------------------------------------------------------------

def filtrar_por_categoria
  transacoes = carregar_transacoes

  categoria = pedir_texto_obrigatorio("Digite a categoria: ").downcase

  resultado = transacoes.select do |transacao|
    transacao["categoria"].downcase == categoria
  end

  if resultado.empty?
    puts "Nenhuma transação encontrada nessa categoria."
    return
  end

  puts
  puts "===== RESULTADO POR CATEGORIA ====="

  resultado.each do |transacao|
    imprimir_transacao(transacao)
  end
end

# ------------------------------------------------------------
# EXCLUIR TRANSAÇÃO
# ------------------------------------------------------------

def excluir_transacao
  transacoes = carregar_transacoes

  if transacoes.empty?
    puts "Nenhuma transação cadastrada para excluir."
    return
  end

  listar_transacoes

  print "Digite o número da transação que deseja excluir: "
  numero = gets.chomp.to_i
  indice = numero - 1

  if indice < 0 || indice >= transacoes.length
    puts "Número inválido."
    return
  end

  transacao_removida = transacoes.delete_at(indice)
  salvar_transacoes(transacoes)

  puts
  puts "Transação excluída com sucesso:"
  imprimir_transacao(transacao_removida)
end

# ------------------------------------------------------------
# FILTRAR POR MÊS
# ------------------------------------------------------------

def filtrar_por_mes
  transacoes = carregar_transacoes
  mes_ano = pedir_mes_ano

  resultado = transacoes.select do |transacao|
    transacao["data"].end_with?(mes_ano)
  end

  if resultado.empty?
    puts "Nenhuma transação encontrada em #{mes_ano}."
    return
  end

  puts
  puts "===== TRANSAÇÕES DE #{mes_ano} ====="

  resultado.each do |transacao|
    imprimir_transacao(transacao)
  end

  receitas = resultado
    .select { |transacao| transacao["tipo"] == "receita" }
    .sum { |transacao| transacao["valor"] }

  despesas = resultado
    .select { |transacao| transacao["tipo"] == "despesa" }
    .sum { |transacao| transacao["valor"] }

  saldo = receitas - despesas

  puts
  puts "===== RESUMO DO MÊS ====="
  puts "Receitas: #{formatar_moeda(receitas)}"
  puts "Despesas: #{formatar_moeda(despesas)}"
  puts "Saldo: #{formatar_moeda(saldo)}"
end

# ------------------------------------------------------------
# RELATÓRIO POR CATEGORIA
# ------------------------------------------------------------

def relatorio_por_categoria
  transacoes = carregar_transacoes

  despesas = transacoes.select do |transacao|
    transacao["tipo"] == "despesa"
  end

  if despesas.empty?
    puts "Nenhuma despesa cadastrada para gerar relatório."
    return
  end

  totais_por_categoria = {}

  despesas.each do |despesa|
    categoria = despesa["categoria"]
    valor = despesa["valor"]

    totais_por_categoria[categoria] ||= 0
    totais_por_categoria[categoria] += valor
  end

  puts
  puts "===== RELATÓRIO POR CATEGORIA ====="

  totais_por_categoria.each do |categoria, total|
    puts "#{categoria}: #{formatar_moeda(total)}"
  end

  total_geral = despesas.sum { |despesa| despesa["valor"] }

  puts "--------------------------"
  puts "Total geral de despesas: #{formatar_moeda(total_geral)}"
end

# ------------------------------------------------------------
# RELATÓRIO MENSAL POR CATEGORIA
# ------------------------------------------------------------

def relatorio_mensal_por_categoria
  transacoes = carregar_transacoes
  mes_ano = pedir_mes_ano

  despesas_do_mes = transacoes.select do |transacao|
    transacao["tipo"] == "despesa" && transacao["data"].end_with?(mes_ano)
  end

  if despesas_do_mes.empty?
    puts "Nenhuma despesa encontrada em #{mes_ano}."
    return
  end

  totais_por_categoria = {}

  despesas_do_mes.each do |despesa|
    categoria = despesa["categoria"]
    valor = despesa["valor"]

    totais_por_categoria[categoria] ||= 0
    totais_por_categoria[categoria] += valor
  end

  puts
  puts "===== RELATÓRIO DE #{mes_ano} POR CATEGORIA ====="

  totais_por_categoria.each do |categoria, total|
    puts "#{categoria}: #{formatar_moeda(total)}"
  end

  total_geral = despesas_do_mes.sum { |despesa| despesa["valor"] }

  puts "--------------------------"
  puts "Total de despesas em #{mes_ano}: #{formatar_moeda(total_geral)}"
end

# ------------------------------------------------------------
# LISTAR POR DATA
# ------------------------------------------------------------

def listar_por_data
  transacoes = carregar_transacoes

  if transacoes.empty?
    puts "Nenhuma transação cadastrada."
    return
  end

  puts
  puts "Como você quer ordenar?"
  puts "1 - Mais antigas primeiro"
  puts "2 - Mais recentes primeiro"
  print "Escolha uma opção: "
  opcao = gets.chomp

  transacoes_ordenadas = transacoes.sort_by do |transacao|
    converter_para_data(transacao["data"])
  end

  if opcao == "2"
    transacoes_ordenadas = transacoes_ordenadas.reverse
    titulo = "MAIS RECENTES PRIMEIRO"
  else
    titulo = "MAIS ANTIGAS PRIMEIRO"
  end

  puts
  puts "===== TRANSAÇÕES POR DATA, #{titulo} ====="

  transacoes_ordenadas.each do |transacao|
    imprimir_transacao(transacao)
  end
end

# ------------------------------------------------------------
# EDITAR TRANSAÇÃO
# ------------------------------------------------------------

def editar_transacao
  transacoes = carregar_transacoes

  if transacoes.empty?
    puts "Nenhuma transação cadastrada para editar."
    return
  end

  listar_transacoes

  print "Digite o número da transação que deseja editar: "
  numero = gets.chomp.to_i
  indice = numero - 1

  if indice < 0 || indice >= transacoes.length
    puts "Número inválido."
    return
  end

  transacao = transacoes[indice]

  puts
  puts "Editando transação:"
  imprimir_transacao(transacao)

  puts "Deixe em branco para manter o valor atual."

  print "Nova descrição atual #{transacao["descricao"]}: "
  nova_descricao = gets.chomp.strip
  transacao["descricao"] = nova_descricao unless nova_descricao.empty?

  loop do
    print "Novo valor atual #{formatar_moeda(transacao["valor"])}: "
    entrada_valor = gets.chomp.strip.gsub(",", ".")

    break if entrada_valor.empty?

    novo_valor = entrada_valor.to_f

    if novo_valor > 0
      transacao["valor"] = novo_valor
      break
    else
      puts "Digite um valor maior que zero ou deixe em branco para manter."
    end
  end

  print "Nova categoria atual #{transacao["categoria"]}: "
  nova_categoria = gets.chomp.strip
  transacao["categoria"] = nova_categoria unless nova_categoria.empty?

  loop do
    print "Nova data atual #{transacao["data"]}: "
    nova_data = gets.chomp.strip

    break if nova_data.empty?

    if data_valida?(nova_data)
      transacao["data"] = nova_data
      break
    else
      puts "Data inválida. Use o formato DD/MM/AAAA."
    end
  end

  salvar_transacoes(transacoes)

  puts
  puts "Transação atualizada com sucesso:"
  imprimir_transacao(transacao)
end

# ------------------------------------------------------------
# BUSCAR POR DESCRIÇÃO
# ------------------------------------------------------------

def buscar_por_descricao
  transacoes = carregar_transacoes

  termo = pedir_texto_obrigatorio("Digite uma palavra da descrição: ").downcase

  resultado = transacoes.select do |transacao|
    transacao["descricao"].downcase.include?(termo)
  end

  if resultado.empty?
    puts "Nenhuma transação encontrada com esse termo."
    return
  end

  puts
  puts "===== RESULTADO DA BUSCA ====="

  resultado.each do |transacao|
    imprimir_transacao(transacao)
  end
end

# ------------------------------------------------------------
# EXPORTAR PARA CSV
# ------------------------------------------------------------

def exportar_para_csv
  transacoes = carregar_transacoes

  if transacoes.empty?
    puts "Nenhuma transação cadastrada para exportar."
    return
  end

  preparar_ambiente

  data_exportacao = Date.today.strftime("%Y-%m-%d")
  caminho_csv = "#{PASTA_EXPORTS}/transacoes_#{data_exportacao}.csv"

  CSV.open(caminho_csv, "w", col_sep: ";") do |csv|
    csv << ["Tipo", "Descrição", "Valor", "Categoria", "Data"]

    transacoes.each do |transacao|
      csv << [
        transacao["tipo"],
        transacao["descricao"],
        transacao["valor"],
        transacao["categoria"],
        transacao["data"]
      ]
    end
  end

  puts "Arquivo exportado com sucesso:"
  puts caminho_csv
end

# ------------------------------------------------------------
# LOOP PRINCIPAL DO PROGRAMA
# ------------------------------------------------------------

preparar_ambiente

loop do
  mostrar_menu
  opcao = gets.chomp

  case opcao
  when "1"
    adicionar_transacao("receita")

  when "2"
    adicionar_transacao("despesa")

  when "3"
    listar_transacoes

  when "4"
    ver_saldo

  when "5"
    filtrar_por_categoria

  when "6"
    excluir_transacao

  when "7"
    filtrar_por_mes

  when "8"
    relatorio_por_categoria

  when "9"
    relatorio_mensal_por_categoria

  when "10"
    listar_por_data

  when "11"
    editar_transacao

  when "12"
    buscar_por_descricao

  when "13"
    exportar_para_csv

  when "0"
    puts "Saindo..."
    break

  else
    puts "Opção inválida."
  end
end