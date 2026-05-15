# Controle de Gastos em Ruby

Projeto de terminal desenvolvido em Ruby para controle financeiro pessoal.

A ideia do projeto é praticar fundamentos da linguagem Ruby criando uma aplicação simples, útil e funcional para cadastro, listagem, edição, exclusão e análise de receitas e despesas.

## Funcionalidades

- Adicionar receitas
- Adicionar despesas
- Listar transações
- Ver saldo geral
- Filtrar transações por categoria
- Filtrar transações por mês
- Excluir transações
- Editar transações
- Buscar transações por descrição
- Gerar relatório de despesas por categoria
- Gerar relatório mensal por categoria
- Ordenar transações por data
- Exportar dados para CSV
- Salvar dados em arquivo JSON

## Tecnologias usadas

- Ruby
- JSON
- CSV
- Date
- FileUtils

## Estrutura do projeto

```txt
controle-gastos-ruby/
│
├── app.rb
├── README.md
├── .gitignore
│
├── data/
│   └── transacoes.json
│
└── exports/