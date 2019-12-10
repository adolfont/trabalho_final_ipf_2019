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
    [cabecalho | alunos] = lista_alunos

    alunos
    |> Enum.map(fn aluno -> Enum.zip(cabecalho, aluno) |> Map.new() end)
  end

  @spec filtra_alunos_desistentes(any) :: [any]
  def filtra_alunos_desistentes(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Desistente"))
  end

  @spec filtra_alunos_formados(any) :: [any]
  def filtra_alunos_formados(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Formado"))
  end

  def lista_tempo_de_titulacao_em_dias(lista_mapas) do
    lista_mapas
    |> Enum.map(fn aluno -> processa_campo_tempo_titulacao(aluno["Tempo detitulação"]) end)
  end

  def particiona_por_ano(lista_alunos) do
    for aluno <- lista_alunos do
      ano = aluno["Ingresso regular"] |> obtem_ano()
      {ano, aluno}
    end
    |> Enum.sort(&ordena_por_ano/2)
    |> Enum.group_by(fn {x, _} -> x end, fn {_, x} -> x end)
  end

  def processa_linha_a_linha(stream) do
    stream |> Enum.map(fn x -> String.split(x, ",") end)
  end

  defp processa_campo_tempo_titulacao(tempo_titulacao) do
    tempo_titulacao
    |> String.replace(~r/Mes\(es\)\ e | Dia\(s\)/, "")
    |> String.split(" ")
    |> calcula_tempo_titulacao_dias()
  end

  defp calcula_tempo_titulacao_dias([meses | [dias | _]]) do
    String.to_integer(meses) * 30 + String.to_integer(dias)
  end

  defp obtem_ano(data) do
    Regex.run(~r/(\d{1,2})\/(\d{1,2})\/(\d{4})/, data) |> Enum.reverse() |> hd()
  end

  defp ordena_por_ano({ano1, _}, {ano2, _}) do
    ano1 < ano2
  end
end

lista = TrabalhoFinalIpf2019.cria_lista_de_listas("AlunosPPGCA.csv")

alunos_por_ano =
  lista
  |> TrabalhoFinalIpf2019.cria_mapas_alunos()
  |> TrabalhoFinalIpf2019.filtra_alunos_formados()
  |> TrabalhoFinalIpf2019.particiona_por_ano()

for {ano, lista_alunos} <- alunos_por_ano do
  resultado = lista_alunos |> TrabalhoFinalIpf2019.lista_tempo_de_titulacao_em_dias()
  media = Enum.sum(resultado) / length(resultado)
  IO.puts("Ano = #{ano}, tempo médio de titulação: #{media}")
end

# |> TrabalhoFinalIpf2019.filtra_alunos_desistentes()
# |> TrabalhoFinalIpf2019.lista_tempo_de_titulacao_em_dias()
# |> IO.inspect()

# cabecalho = List.first(lista)

# um_aluno = List.last(lista)
#
# Enum.zip(cabecalho, um_aluno)
# |> IO.inspect()
