defmodule ProcessaArquivoCSV_AlunosPPGCA do
  @moduledoc """
  Documentation for ProcessaArquivoCSV_AlunosPPGCA.
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
    |> processa_tempo_de_titulacao_em_dias()
    |> processa_coeficiente()
  end

  def filtra_alunos_formados(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Formado"))
  end

  def filtra_alunos_desistentes(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Desistente"))
  end

  def lista_tempo_de_titulacao_em_dias(lista_mapas) do
    lista_mapas
    |> Enum.map(fn aluno -> processa_campo_tempo_titulacao(aluno["Tempo detitulação"]) end)
  end

  def calcula_sumario_aluno(lista_alunos, atributo) do
    lista_alunos = Enum.sort(lista_alunos, &(&1[atributo] <= &2[atributo]))

    media = calcula_media(lista_alunos, atributo)

    %{
      min: Map.fetch!(Enum.at(lista_alunos, 0), atributo),
      max: Map.fetch!(Enum.at(lista_alunos, length(lista_alunos) - 1), atributo),
      media: media,
      mediana: calcula_mediana(lista_alunos, atributo),
      desvio_padrao: calcula_desvio_padrao(lista_alunos, media, atributo)
    }
  end

  def calcula_mediana([], _), do: 0

  def calcula_mediana(lista_alunos, atributo) when rem(length(lista_alunos), 2) == 1 do
    Enum.at(lista_alunos, div(length(lista_alunos), 2))
    |> Map.fetch!(atributo)
  end

  def calcula_mediana(lista_alunos, atributo) when rem(length(lista_alunos), 2) == 0 do
    lista_alunos
    |> Enum.slice(div(length(lista_alunos), 2) - 1, 2)
    |> calcula_media(atributo)
  end

  def calcula_media(lista_alunos, atributo) when length(lista_alunos) > 0 do
    Enum.reduce(lista_alunos, 0, fn x, soma -> x[atributo] + soma end) / length(lista_alunos)
  end

  def calcula_media([], _), do: 0

  def calcula_desvio_padrao([], _, _), do: 0

  def calcula_desvio_padrao(lista_alunos, media, atributo) do
    Enum.sum(Enum.map(lista_alunos, fn x -> :math.pow(x[atributo] - media, 2) end))
    |> :math.sqrt()
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

  defp processa_tempo_de_titulacao_em_dias(lista_mapas) do
    lista_mapas
    |> Enum.map(fn aluno -> processa_tempo_titulacao_aluno(aluno) end)
  end

  defp processa_tempo_titulacao_aluno(aluno) do
    %{aluno | "Tempo detitulação" => processa_campo_tempo_titulacao(aluno["Tempo detitulação"])}
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

  defp processa_coeficiente(lista_mapas) do
    lista_mapas
    |> Enum.map(fn aluno -> converte_coeficiente_para_float(aluno) end)
  end

  defp converte_coeficiente_para_float(aluno) do
    {coeficiente, _} =
      String.replace(aluno["Coeficiente"], ",", ".")
      |> Float.parse()

    %{aluno | "Coeficiente" => coeficiente}
  end

  def mostra_estatisticas_gerais() do
    IO.puts("Calculando Coeficiente")

    ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas("AlunosPPGCA.csv")
    |> ProcessaArquivoCSV_AlunosPPGCA.cria_mapas_alunos()
    |> ProcessaArquivoCSV_AlunosPPGCA.filtra_alunos_formados()
    |> ProcessaArquivoCSV_AlunosPPGCA.calcula_sumario_aluno("Coeficiente")
    |> IO.inspect()

    IO.puts("Calculando Tempo de Titulação")

    ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas("AlunosPPGCA.csv")
    |> ProcessaArquivoCSV_AlunosPPGCA.cria_mapas_alunos()
    |> ProcessaArquivoCSV_AlunosPPGCA.filtra_alunos_formados()
    |> ProcessaArquivoCSV_AlunosPPGCA.calcula_sumario_aluno("Tempo detitulação")
    |> IO.inspect()
  end

  def mostra_estatisticas_ano_a_ano() do
    IO.puts("Calculando Tempo de Titulação Ano a Ano")

    lista = ProcessaArquivoCSV_AlunosPPGCA.cria_lista_de_listas("AlunosPPGCA.csv")

    alunos_por_ano =
      lista
      |> ProcessaArquivoCSV_AlunosPPGCA.cria_mapas_alunos()
      |> ProcessaArquivoCSV_AlunosPPGCA.filtra_alunos_formados()
      |> ProcessaArquivoCSV_AlunosPPGCA.particiona_por_ano()

    for {ano, lista_alunos} <- alunos_por_ano do
      IO.puts("Ano = #{ano} com #{length(lista_alunos)} aluno(a)s")

      lista_alunos
      |> ProcessaArquivoCSV_AlunosPPGCA.calcula_sumario_aluno("Tempo detitulação")
      |> IO.inspect()
    end
  end
end

# ProcessaArquivoCSV_AlunosPPGCA.mostra_estatisticas_gerais()
# ProcessaArquivoCSV_AlunosPPGCA.mostra_estatisticas_ano_a_ano()
