defmodule ProcessaArquivoCSV_AlunosPPGCATest do
  use ExUnit.Case
  doctest ProcessaArquivoCSV_AlunosPPGCA

  @nome_arquivo "AlunosPPGCA.csv"

  test "Obtém último elemento" do
    lista = ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas(@nome_arquivo)

    cabecalho = List.first(lista)

    um_aluno = List.last(lista)

    ultimo = Enum.zip(cabecalho, um_aluno)

    {_, codigo} = Enum.find(ultimo, fn {x, _} -> x == "Código" end)

    assert codigo == "1904752"
  end

  test "Calcula tempo de titulação formados" do
    lista = ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas(@nome_arquivo)

    resultado =
      lista
      |> ProcessaArquivoCSV_AlunosPPGCA.cria_mapas_alunos()
      |> ProcessaArquivoCSV_AlunosPPGCA.filtra_alunos_formados()

    media =
      Enum.reduce(resultado, 0, fn x, soma -> x["Tempo detitulação"] + soma end) /
        length(resultado)

    assert media == 883
  end

  test "Calcula tempo de titulação desistentes" do
    lista = ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas(@nome_arquivo)

    resultado =
      lista
      |> ProcessaArquivoCSV_AlunosPPGCA.cria_mapas_alunos()
      |> ProcessaArquivoCSV_AlunosPPGCA.filtra_alunos_desistentes()

    media =
      Enum.reduce(resultado, 0, fn x, soma -> x["Tempo detitulação"] + soma end) /
        length(resultado)

    assert media == 1710.7586206896551
  end
end
