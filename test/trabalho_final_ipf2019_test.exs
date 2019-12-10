defmodule TrabalhoFinalIpf2019Test do
  use ExUnit.Case
  doctest TrabalhoFinalIpf2019

  @nome_arquivo "AlunosPPGCA.csv"

  test "Obtém último elemento" do
    lista = TrabalhoFinalIpf2019.cria_lista_de_listas(@nome_arquivo)

    cabecalho = List.first(lista)

    um_aluno = List.last(lista)

    ultimo = Enum.zip(cabecalho, um_aluno)

    {_, codigo} = Enum.find(ultimo, fn {x, _} -> x == "Código" end)

    assert codigo == "1904752"
  end

  test "Calcula tempo de titulação formados" do
    lista = TrabalhoFinalIpf2019.cria_lista_de_listas(@nome_arquivo)

    resultado =
      lista
      |> TrabalhoFinalIpf2019.cria_mapas_alunos()
      |> TrabalhoFinalIpf2019.filtra_alunos_formados()
      |> TrabalhoFinalIpf2019.lista_tempo_de_titulacao_em_dias() 

    
    media = Enum.reduce( resultado , 0 , fn x, soma ->  x["Tempo detitulação"]  + soma end ) / length(resultado)
    assert media == 883
  end

  test "Calcula tempo de titulação desistentes" do
    lista = TrabalhoFinalIpf2019.cria_lista_de_listas(@nome_arquivo)

    resultado =
      lista
      |> TrabalhoFinalIpf2019.cria_mapas_alunos()
      |> TrabalhoFinalIpf2019.filtra_alunos_desistentes()
      |> TrabalhoFinalIpf2019.lista_tempo_de_titulacao_em_dias() 

    
    media = Enum.reduce( resultado , 0 , fn x, soma ->  x["Tempo detitulação"]  + soma end ) / length(resultado)
    assert media == 1710.7586206896551
  end
end
