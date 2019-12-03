defmodule TrabalhoFinalIpf2019 do
  @moduledoc """
  Documentation for TrabalhoFinalIpf2019.
  """

  def obtem_stream(nome_arquivo) do
    File.stream!(nome_arquivo)
  end

  def troca_virgula_de_coeficiente_por_ponto(string) do
    String.replace(string, ~r/\"([0-9])\,([0-9])\"/, "\\1.\\2") |> String.trim()
  end

  def cria_lista_de_listas(nome_arquivo) do
    obtem_stream(nome_arquivo)
    |> Stream.map(fn line -> troca_virgula_de_coeficiente_por_ponto(line) end)
    |> processa_linha_a_linha()
  end

  def cria_mapas_alunos(lista_alunos) do
    [ cabecalho | alunos ] = lista_alunos
    Enum.map(alunos, fn aluno -> Enum.zip(cabecalho, aluno) |> Map.new end )
  end

  def processa_linha_a_linha(stream) do
    stream |> Enum.map(fn x -> String.split(x, ",") end)
  end
end

lista = TrabalhoFinalIpf2019.cria_lista_de_listas("AlunosPPGCA.csv")

cabecalho = List.first(lista)

um_aluno = List.last(lista)

Enum.zip(cabecalho, um_aluno)
|> IO.inspect()
