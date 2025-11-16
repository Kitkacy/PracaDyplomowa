% filepath: /Users/vincent/Studia/PracaInżynierska/SurvivorsClone_Base/Survivors Clone/inzynierka.tex
\documentclass[12pt,twoside,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[polish]{babel}
\usepackage{geometry}
\geometry{
    a4paper,
    top=2.5cm,
    bottom=2.5cm,
    left=3cm,      % 2.5cm + 0.5cm na oprawę
    right=2.5cm,
    bindingoffset=0cm
}
\usepackage{setspace}
\usepackage{titling}
\usepackage{float}
\usepackage{graphicx}
\usepackage{amsmath}
\usepackage{array}
\usepackage{multirow} 
\usepackage[table]{xcolor}
\usepackage{hyperref}
\usepackage{ebgaramond}
\usepackage{tgtermes}  % Times New Roman dla całego dokumentu
\usepackage{titlesec}  % Do formatowania tytułów rozdziałów

% Interlinia pojedyncza i wcięcie pierwszego wiersza 0.7cm
\singlespacing
\setlength{\parindent}{0.7cm}

% Formatowanie tytułów zgodnie z wymaganiami
\titleformat{\section}
  {\normalfont\fontsize{14}{16}\bfseries}{\thesection.}{1em}{}
\titleformat{\subsection}
  {\normalfont\fontsize{13}{15}\bfseries}{\thesubsection.}{1em}{}
\titleformat{\subsubsection}
  {\normalfont\fontsize{12}{14}\bfseries}{\thesubsubsection.}{1em}{}

% Numeracja dwustopniowa dla tabel i rysunków
\renewcommand{\thetable}{\thesection.\arabic{table}}
\renewcommand{\thefigure}{\thesection.\arabic{figure}}
\renewcommand{\theequation}{\thesection.\arabic{equation}}

% Formatowanie podpisów tabel i rysunków (Times New Roman 10pt)
\usepackage{caption}
\captionsetup{
    font={small},           % 10pt
    labelfont={bf},
    justification=centering,
    skip=10pt
}
\captionsetup[table]{position=top}
\captionsetup[figure]{position=bottom}

% Dodanie ramki do wszystkich obrazków (1pt)
\setlength\fboxsep{0pt}
\setlength\fboxrule{1pt}
\let\oldincludegraphics\includegraphics
\renewcommand{\includegraphics}[2][]{\fbox{\oldincludegraphics[#1]{#2}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definicja strony tytułowej
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\makeatletter

% Deklaracja komend dla metadanych
\newcommand\uczelnia[1]{\renewcommand\@uczelnia{#1}}
\newcommand\@uczelnia{}

\newcommand\wydzial[1]{\renewcommand\@wydzial{#1}}
\newcommand\@wydzial{}

\newcommand\kierunek[1]{\renewcommand\@kierunek{#1}}
\newcommand\@kierunek{}

\newcommand\specjalnosc[1]{\renewcommand\@specjalnosc{#1}}
\newcommand\@specjalnosc{}

\newcommand\promotor[1]{\renewcommand\@promotor{#1}}
\newcommand\@promotor{}

\newcommand\kvpl[1]{\renewcommand\@kvpl{#1}}
\newcommand\@kvpl{}

% Zmienna logiczna do rozróżnienia pracy inżynierskiej/magisterskiej
\newif\ifMaster % domyślnie false (praca inżynierska)

% Definicja strony tytułowej
\def\maketitle{%
  \pagestyle{empty}%
  \fontfamily{\ebgaramond@family}\selectfont
  
  % Nagłówek: Uczelnia i Wydział
  \vspace*{-1.5cm}
  {\centering
    {\fontsize{20pt}{22pt}\bfseries\selectfont \@uczelnia}\\[5pt]
    {\fontsize{16pt}{18pt}\bfseries\selectfont \@wydzial}\\[1pt]
    \hrule
  }
  
  % Kierunek i Specjalność
  \vspace{24pt}
  {\raggedright\fontsize{14pt}{16pt}\selectfont
    \begin{tabular}{@{}ll}
      Kierunek: & {\bfseries \@kierunek}\\
      Specjalność: & {\bfseries \@specjalnosc}\\
    \end{tabular}
  }
  
  % Tytuł pracy (wycentrowany bez ramki)
  \vspace{70pt}
  {\centering\fontsize{24pt}{26pt}\selectfont
    {\fontsize{26pt}{28pt}\selectfont P}RACA {\fontsize{26pt}{24pt}\selectfont D}YPLOMOWA\\[-5pt]
    \ifMaster 
      {\fontsize{26pt}{28pt}\selectfont M}AGISTERSKA
    \else 
      {\fontsize{26pt}{28pt}\selectfont I}NŻYNIERSKA
    \fi
  \par}
  
  % Tytuł i autor (wycentrowane bez ramki)
  \vspace{50pt}
  {\centering
    {\fontsize{18pt}{20pt}\bfseries\selectfont \@title}\\[15mm]
    {\fontsize{16pt}{18pt}\selectfont \@author}
  \par}
  
  % Opiekun pracy
  \vspace{60pt}
  {\centering
    {\fontsize{14pt}{16pt}\selectfont Opiekun pracy}\\[2mm] 
    {\fontsize{14pt}{16pt}\bfseries\selectfont \@promotor}
  \par}
  
  % Słowa kluczowe, linia i data
  \vfill
  \noindent
  {\fontsize{12pt}{14pt}\selectfont Słowa kluczowe: \@kvpl}
  \vspace{1.3cm}
  \hrule
  \vspace*{0.3cm}
  {\centering
    {\fontsize{14pt}{16pt}\selectfont \@date}
  \par}
  
  \normalfont
  \cleardoublepage
}
\makeatother

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Metadane dokumentu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\title{Projekt gry 2D inspirowanej gatunkiem roguelite w Godot}
\author{Wincenty Wensker}
\uczelnia{Politechnika Wrocławska}
\wydzial{Wydział Informatyki i Telekomunikacji}
\kierunek{Informatyka techniczna (ITE)}
\specjalnosc{Grafika i systemy multimedialne (IGM)}
\promotor{dr inż. Tomasz Kapłon}
\kvpl{roguelike, tower defense, Godot Engine, GDScript, system progresji wykładniczej}
\date{WROCŁAW, 2025}

\begin{document}

\maketitle
\tableofcontents
\newpage

\section{Opis projektu}

\subsection{Wprowadzenie}
Projekt zakłada stworzenie gry komputerowej na komputery osobiste, wykonanej z użyciem silnika Godot. Gra silnie inspiruje się gatunkiem rouge-like, łącząc ze sobą styl gry spopularyzowany przez przedstawiciela gatunku "Vampire survivors" oraz elementy gatunku tower defense. 


\subsection{Opis Gry}
Projektowana gra stanowi innowacyjne połączenie dwóch popularnych gatunków: roguelike survival oraz tower defense. Gracz wciela się w postać, której zadaniem jest przetrwanie przez określony czas (30 minut) w obliczu narastających fal przeciwników. Rozgrywka łączy dynamiczne elementy akcji z przemyślanym planowaniem strategicznym.

Kluczową cechą gry jest dwutorowy system rozgrywki. Z jednej strony, gracz aktywnie porusza się po mapie, automatycznie atakując przeciwników znajdujących się w zasięgu, zbierając doświadczenie i rozwijając swoją postać poprzez system ulepszeń. Z drugiej strony, wykorzystując zebrane zasoby, może strategicznie rozmieszczać struktury obronne takie jak wieże, barykady i miny oraz investować w drony obronne, które wspierają go w obronie kluczowego punktu mapy zwanego Bazą.

System progresji charakteryzuje się wykładniczym skalowaniem zarówno mocy gracza, jak i trudności gry. Wraz z upływem czasu pojawiają się coraz silniejsze typy przeciwników (tiery), a ich liczba rośnie w tempie wykładniczym. Jednocześnie gracz może wielokrotnie ulepszać swoje statystyki oraz struktury obronne, co prowadzi do eskalacji mocy obu stron konfliktu.

Gra kończy się zwycięstwem po przetrwaniu wyznaczonego czasu lub porażką w przypadku śmierci gracza bądź zniszczenia Bazy. Projekt kładzie nacisk na zbalansowanie mechanik automatycznych (auto-atak) z aktywnymi decyzjami strategicznymi (budowanie, wybór ulepszeń, pozycjonowanie), tworząc wymagającą, acz prostą rozgrywkę.

\subsection{Analiza stanu techniki}

Gatunek roguelike oraz tower defense są dobrze ugruntowane w branży gier wideo. Poniżej przedstawiono analizę istniejących rozwiązań oraz technologii wykorzystanych w projekcie.

\subsubsection{Godot Engine 4.5}
Godot to otwartoźródłowy silnik do tworzenia gier 2D i 3D, wydany na licencji MIT w 2014 roku. Wersja 4.5 wprowadza znaczące ulepszenia w zakresie wydajności renderowania 2D oraz swojego wewnętrznego systemu skryptowego GDScript. Jego niskie wymagania systemowe, dobra dokumentacja, społeczność internetowa oraz prosty sposób reprezentowania elementów gry jako węzłów (Nodes) czyni go idealnym do małych projektów 2D a niskiej kompleksowości.

\subsubsection{Vampire Survivors}
Gra "Vampire Survivors" (2022) spopularyzowała nowoczesną interpretację gatunku roguelike survival, charakteryzującą się automatycznym atakowaniem przeciwników, systemem poziomów i ulepszeń wybieranych przez gracza oraz wykładniczym wzrostem trudności. Jednocześnie gra zachowuje minimalistyczny interface i prostotę rozgrywki, czyniąc ją przystępną i wciągającą.

\subsubsection{Tower Defense – klasyczne rozwiązania}
Gry tower defense (np. "Bloons TD", "Kingdom Rush") charakteryzują się z kolei strategicznym rozmieszczaniem struktur obronnych w celu pokonywania kolejnych fal przeciwników o rosnącej sile. Pokonywanie przeciwników pozwala ulpeszać budowle i budować kolejne tworząc prostą pętlę rozgrywki (game loop).

\subsubsection{Systemy levelowania}
Idea zapoczątkowana przez wczesne stołowe gry wojenne (tabletop wargaming), została wymyślona w celu nadania graczowi poczucia progresji oraz lepszego przywiązania się do odgrywanej postaci, współcześnie wiele gier RPG i roguelike wykorzystuje ją jako podstawę budowania trudności gry. W przypadku projektów podobnych struktura "Vampire Survivors”, progresja zazwyczaj odbywa się wykładniczo, aniżeli liniowo. W ten sposób w raz z progresją gry, staje się ona dynamiczniejsza i bardziej wymagająca, co sprzyja gatunkowi rouglike, poprzez założenie że gracz powinien przegrywać i uczyć się z każdym podejściem do gry.

\subsubsection{Analiza podobnych projektów}
W ekosystemie Godot istnieją projekty łączące elementy roguelike i tower defense:
\begin{itemize}
    \item \textbf{Survivor-like templates} - podstawowe implementacje mechanik Vampire Survivors
    \item \textbf{Tower defense kits} - gotowe systemy budowania i targetowania
    \item \textbf{Brak hybryd} - praktycznie brak projektów łączących oba gatunki z progresją wykładniczą
\end{itemize}

\subsection{Podsumowanie}
Celem projektu jest stworzenie unikalnej hybrydy gatunków roguelike i tower defense, wykorzystującej silnik Godot 4.5. Innowacyjność projektu polega na połączeniu automatycznych mechanik survivala z aktywnym budowaniem struktur obronnych oraz implementacji kompleksowego systemu progresji wykładniczej dla wszystkich aspektów rozgrywki.


\section{Opis mechanik obsługiwanych przez projektowany system gry}

Poniżej opisane zostały kluczowe mechaniki rozgrywki, które będą zaimplementowane w systemie gry. Wybrane systemy pozwolą na stworzenie kompleksowej i zbalansowanej rozgrywki łączącej elementy roguelike i tower defense.

\subsection{Sterowanie postacią gracza}
\subsubsection{Opis mechaniki}
Gracz kontroluje postać za pomocą klawiatury (klawisze WASD lub strzałki), poruszając się w dwuwymiarowej przestrzeni mapy. Postać może poruszać się w ośmiu kierunkach (góra, dół, lewo, prawo oraz po przekątnych).

\begin{figure}[H]
    \centering
    \includegraphics[width=0.4\textwidth]{Podstawy/Movement.png}
    \caption{Postać gracza porusza się w ośmiu kierunkach za pomocą klawiatury.}
    \label{fig:movement}
\end{figure}

\subsection{System zdrowia i regeneracji}
Zarówno gracz, jak i baza oraz struktury obronne posiadają system punktów życia reprezentowany przez zielone paski zdrowia. Pasek zmienia kolor z zielonego przez żółty na czerwony w miarę utraty życia, co daje wizualną informację zwrotną o stanie obiektu.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Podstawy/Baza.png}
    \caption{Paski reprezentujące aktualny stan wartości punktów życia postaci i bazy.}
    \label{fig:healthbars}
\end{figure}

\subsubsection{Mechanizm regeneracji:}
    Pick-upy zdrowia (zielony krzyżyk) pojawiają się automatycznie pod bazą co 2 minuty. Istnieje również 1\% szansa na wypadnięcie pick-upu po eliminacji przeciwnika. Pick-upy automatyczne zbierane są przy zbliżeniu się do nich postaci, na zasadzie podobnej do magnetyzmu.


\begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Podstawy/Regeneracja.png}
    \caption{Timer odliczający generację kolejnego pick-upu przez bazę.}
    \label{fig:health_regen_timer}
\end{figure}

 Bazę można również naprawić poprzez zbliżenie się do niej i wydanie zasobów używanych do konstrukcji budowli.

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Podstawy/rapair.png}
    \caption{Prompt pojawiający się przy podejściu do uszkodzonej bazy}
    \label{fig:base_repair_prompt}
\end{figure}

\subsection{System przeciwników i targetowania}
Przeciwnicy generują się poza obszarem widocznym przez kamerę i posiadają inteligentny system targetowania. Każdy wróg przy spawnie losowo wybiera cel spośród dostępnych opcji:

\subsubsection{Możliwe cele (równomierny rozkład prawdopodobieństwa):}
\begin{itemize}
    \item Gracz - 33,3\% szansy
    \item Baza  - 33,3\% szansy
    \item Wieże obronne - 33,3\% szansy (jeśli istnieją) 
    \end{itemize}
    Jeżeli żadna wieża nie została zbudowana, prawdopodobieństwo rozkłada się 50\% dla Gracza i 50\% dla bazy. Wraz z zwiększającą się ilością wież, prawdopodobieństwo rozkłada się równomiernie, tak że każda wieża, baza i gracz mają tą samą szansę bycia celem. Ma to na celu zapobiegnięcie sytuacji w której gracz posiada zbyt wiele wież, gdyż nie są one atakowane przez wrogów.


\subsubsection{Zachowanie przeciwników:}

Wrogowie poruszają się w linii prostej do wybranego celu. Zadają oni obrażenia przy kontakcie. Jeśli napodkają na przeszkodę taką jak barykada lub głaz, będą ją atakowali do zniszczenia. Pozostawiają oni również zasoby (niebieskie kwadraty) po eliminacji


 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Podstawy/kierunekWrogow.png}
    \caption{Przykładowe kierunki wrogów podczas rozgrywki.}
    \label{fig:enemy_directions}
\end{figure}

\subsection{System budowania struktur obronnych}

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/uiBudowy.png}
    \caption{Elementy wizualne systemu budowy w grze.}
    \label{fig:building_ui}
\end{figure}

Gracz może budować różne struktury obronne wykorzystując zebrane zasoby (niebieskie kwadraty). System budowania składa się z następujących elementów:

\begin{itemize}
    \item \textbf{Wyboru struktury} z menu budowania za pomocą myszki.
    \item \textbf{Tryb podglądu}, czyli półprzezroczystej wizualizacji struktury podążającej za kursorem myszy.
    \item \textbf{Walidacji miejsca} będącej sprawdzeniem czy można postawić strukturę w danym miejscu, na co wpływa odległość od innych obiektów oraz kolizje z nimi.
    \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/walidacja.png}
    \caption{Zmieniające się kolory spritu w zależności od możliwości budowy w trybie podglągu.}
    \label{fig:building_validation}
\end{figure}
    \item \textbf{Potwierdzenia} poprzez kliknięcie lewym przyciskiem myszy.
    \item \textbf{Anulowania postawienia budowli} poprzez kliknięcie prawym przyciskiem myszy.
\end{itemize}

\subsubsection{Dostępne struktury:}

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/bronie.png}
    \caption{Spritey reprezentujące dostępne budowle podczas rozgrywki.}
    \label{fig:building_sprites}
\end{figure}

\begin{enumerate}
    \item \textbf{Wieżyczka (Tower)} - automatycznie atakuje przeciwników w zasięgu.
    \item \textbf{Barykada (Barricade)} - blokuje ruch przeciwników, można obracać klawiszem Q.
    \item \textbf{Mina (Mine)} - eksploduje gdy wróg wejdzie w zasięg, zadając obrażenia obszarowe.
    \item \textbf{Drony (Drones)} - orbitują wokół gracza i atakują przeciwników przy kontakcie.
\end{enumerate}

\subsection{System progresji i ulepszeń}

Gra wykorzystuje system poziomów doświadczenia z możliwością wyboru ulepszeń. Po zebraniu wymaganej ilości doświadczenia gracz przechodzi na wyższy poziom i może wybrać jedno z trzech losowych ulepszeń.

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/paseklevelu.png}
    \caption{Elementy UI reprezentujące system levelowania}
    \label{fig:level_bar_ui}
\end{figure}

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/levelup.png}
    \caption{Pop-up towarzyszący wejściu na wyższy poziom.}
    \label{fig:levelup_popup}
\end{figure}

\subsubsection{Typy ulepszeń :}
\begin{table}[H]
    \caption{Lista dostępnych ulepszeń w grze.}
    \centering
    \begin{tabular}{|l|l|p{6.5cm}|}
        \hline
        \rowcolor{blue!30}
        \textbf{Kategoria} & \textbf{Nazwa ulepszenia} & \textbf{Opis} \\
        \hline
        \multirow{5}{*}{Gracz} 
        & Swift Feet & Zwiększa prędkość poruszania się gracza o 10\%. \\
        \cline{2-3}
        & Sharp Weapons & Zwiększa obrażenia broni gracza o 10\%. \\
        \cline{2-3}
        & Quick Draw & Zwiększa szybkostrzelność (fire rate) gracza o 10\%. \\
        \cline{2-3}
        & Sturdy Body & Zwiększa maksymalne punkty życia gracza o 10\%. \\
        \cline{2-3}
        & Longer Reach & Zwiększa zasięg automatycznego zbierania zasobów i pick-upów o 10\%. \\
        \hline
        \multirow{3}{*}{Wieżyczka} 
        & Reinforced Towers & Zwiększa obrażenia zadawane przez wszystkie wieże o 10\%. \\
        \cline{2-3}
        & Rapid Fire Towers & Zwiększa częstotliwość strzałów wież o 10\% (szybsze ataki. \\
        \cline{2-3}
        & Fortified Towers & Zwiększa wytrzymałość (HP) wszystkich wież o 10\%. \\
        \hline
        \multirow{3}{*}{Dron} 
        & Enhanced Drones & Zwiększa obrażenia zadawane przez drony orbitujące wokół gracza o 10\%. \\
        \cline{2-3}
        & Swift Drones & Zwiększa prędkość rotacji dronów wokół gracza o 10\%. \\
        \cline{2-3}
        & Armored Drones & Zwiększa wytrzymałość (HP) wszystkich dronów o 10\%. \\
        \hline
        Baza 
        & Reinforced Base & Zwiększa maksymalne punkty życia obelisku (bazy) o 10\%. \\
        \hline
        Mina 
        & Explosive Mines & Zwiększa obrażenia eksplozji min o 10\% (efekt obszarowy). \\
        \hline
    \end{tabular}
    \label{tab:upgrades}
\end{table}

    Wszystkie ulepszenia stackują się wykładniczo (multiplikatywnie) i wpływają zarówno na nowe, jak i istniejące obiekty. Każde ulepszenie zwiększa mnożnik o 10\%: \\
    $multiplier = multiplier \times \textit{1.1.}$ \\
    Nie zaimplementowano górnego limitu poziomów co sprawia że jedynym ograniczeniem gracza jest czas 30 minut rozgrywki (infinite scaling).


\subsection{System trudności i skalowania przeciwników}

System trudności w grze opiera się na dwóch mechanizmach: wykładniczym wzroście liczby przeciwników oraz wprowadzaniu coraz silniejszych wariantów wrogów (tierów).

\begin{table}[H]
    \caption{Progresja mnożnika trudności.}
    \centering
    \begin{tabular}{|c|c|p{7cm}|}
        \hline
        \rowcolor{blue!30}
        \textbf{Czas [min]} & \textbf{Mnożnik trudności} & \textbf{Efekt} \\
        \hline
        1 & 1.1 & 10\% więcej przeciwników niż na starcie \\
        \hline
        2 & 1.21 & 21\% więcej przeciwników \\
        \hline
        3 & 1.33 & 33\% więcej przeciwników \\
        \hline
        5 & 1.61 & 61\% więcej przeciwników \\
        \hline
        10 & 2.59 & 159\% więcej przeciwników (2.6x bazowa ilość) \\
        \hline
    \end{tabular}
    \label{tab:difficulty_scaling}
\end{table}

Mnożnik trudności obliczany jest według wzoru: $difficulty = 1.1^{minutes}$, co oznacza 10\% wzrost co minutę. Wpływa on na częstotliwość spawnu oraz liczbę równocześnie pojawiających się przeciwników.

\begin{table}[H]
    \caption{Tiery przeciwników i ich statystyki.}
    \centering
    \begin{tabular}{|c|c|l|c|c|c|}
        \hline
        \rowcolor{red!30}
        \textbf{Tier} & \textbf{Czas [min]} & \textbf{Nazwa} & \textbf{HP} & \textbf{Prędkość} & \textbf{Obrażenia} \\
        \hline
        0 & 0-3 & Kobold Weak & 15 & 25 & 5 \\
        \hline
        1 & 3-6 & Kobold Strong 1 & 23 & 23 & 8 \\
        \hline
        2 & 6-9 & Kobold Strong 2 & 34 & 21 & 12 \\
        \hline
        3 & 9-12 & Kobold Strong 3 & 51 & 19 & 18 \\
        \hline
        4 & 12-15 & Kobold Strong 4 & 77 & 17 & 27 \\
        \hline
        5 & 15+ & Kobold Strong 5 & 115 & 15 & 40 \\
        \hline
    \end{tabular}
    \label{tab:enemy_tiers}
\end{table}

Nowy tier przeciwników pojawia się co 3 minuty. Każdy kolejny tier charakteryzuje się wyższymi punktami życia (HP rośnie w tempie $\sim$1.5x na tier) oraz większymi obrażeniami (damage rośnie w tempie $\sim$1.5x na tier). W ramach kompensacji za siłę przeciwników oraz dłuższą przeżywalność (time to kill), ich prędkość poruszania spada w każdym kolejnym tierze.

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/sprites2d.png}
    \caption{Sprity 2D reprezentujące każdy tier przeciwników.}
    \label{fig:enemy_tier_sprites}
\end{figure}

\subsection{System zasobów (niebieskie kwadraty)}
Zasoby służą jako uniwersalna waluta do budowania struktur oraz naprawy bazy. Po pokonaniu przeciwnika, zawsze upuszcza on jedną jedną jednostkę zasobów, reprezentowaną przez niebieskie kwadraty. Zasoby pozostają na ziemi przez 30 sekund przed zniknięciem jeśli nie zostaną w porę zebrane przez gracza. Gracz podobnie jak w przypadku pick-upów zdrowia, podnosi zasoby automatycznie będąc w wystarczająco bliskiej odległości od nich.


\begin{table}[H]
    \caption{Wykorzystanie zasobów}
    \centering
    \begin{tabular}{|l|c|p{7cm}|}
        \hline
        \rowcolor{orange!30}
        \textbf{Akcja} & \textbf{Koszt} & \textbf{Dodatkowe informacje} \\
        \hline
        Budowa wieży & 30 zasobów & Struktura obronna atakująca przeciwników w zasięgu. \\
        \hline
        Budowa barykady & 15 zasobów & Struktura blokująca ruch przeciwników. \\
        \hline
        Budowa miny & 15 zasobów & Jednorazowa pułapka zadająca obrażenia obszarowe. \\
        \hline
        Zakup drona & 20 zasobów & Struktura poruszająca się wokół gracza, atakująca przeciwników przy kontakcie. Gracz może maksymalnie posiadać 5 aktywnych dronów wokół siebie. \\
        \hline
        Naprawa bazy & X zasobów & Z każdą chwilą przytrzymywania guzika naprawy przy bazie, zasoby są wymieniane na jej zdrowie, gdzie 1 zasób jest równy 2 HP bazy. \\
        \hline
    \end{tabular}
    \label{tab:resource_usage}
\end{table}


\subsection{Warunki zwycięstwa i porażki}

Warunkiem zwycięstwa jest przetrwanie przez 30 minut, przez co rozumie się utrzymanie wartości HP postaci gracza oraz bazy powyżej 0 przed upływem tego czasu. Niespełnienie tego warunku kończy grę ekranem porażki, wyświetlającym ilość czasu trwania gry, oraz daje opcje powrotu do menu głównego, wyjścia z programu tudzież restartu gry.

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/gameover.png}
    \caption{Ekran końca gry.}
    \label{fig:game_over_screen}
\end{figure}

W przypadku zwycięstwa gracza, zostaje wyświetlony ekran zwycięstwa, pokazujący ile doświadczenia (EXP) udało się zebrać graczowi podczas rozgrywki oraz na jaki finalny poziom udało mu się wejść. Poza tym daje on te same opcje co ekran końca gry.

 \begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{Bronie/victory.png}
    \caption{Ekran zwycięstwa.}
    \label{fig:victory_screen}
\end{figure}

\section{Opis funkcjonalny}

Na podstawie powyższych mechanik rozgrywki, została przygotowana analiza funkcjonalna systemu gry. System powstał zmyślą o wykorzystaniu rozrywkowym jako gra komputerowa.

\subsection{Wymagania funkcjonalne}

Na podstawie analizy mechanik rozgrywki oraz założeń projektowych, zostały wyodrębnione następujące wymagania funkcjonalne:

\subsubsection{Moduł rozgrywki głównej}

\begin{enumerate}
    \item \textbf{WF-G-1}: System umożliwi płynne sterowanie postacią gracza za pomocą klawiatury (WASD lub strzałki).
    \item \textbf{WF-G-2}: System zapewni kolizje postaci z przeszkodami i krawędziami mapy.
    \item \textbf{WF-G-3}: System wyświetli paski życia dla gracza, bazy i struktur obronnych z kolorową reprezentacją stanu zdrowia.
    \item \textbf{WF-G-4}: System umożliwi automatyczne zbieranie zasobów i pick-upów w zasięgu magnesu gracza.
    \item \textbf{WF-G-5}: System zatrzyma grę i wyświetli ekran zwycięstwa po 30 minutach rozgrywki.
    \item \textbf{WF-G-6}: System zatrzyma grę i wyświetli ekran porażki gdy życie gracza lub bazy spadnie do 0.
    \item \textbf{WF-G-7}: System umożliwi pauzę gry klawiszem ESC oraz specjalną pauzę fotograficzną klawiszem L.
\end{enumerate}

\subsubsection{Moduł systemu przeciwników}

\begin{enumerate}
    \item \textbf{WF-P-1}: System będzie spawmował przeciwników poza ekranem w losowych lokalizacjach.
    \item \textbf{WF-P-2}: System umożliwi przeciwnikom wybór celu z dostępnych opcji (gracz, baza, wieże).
    \item \textbf{WF-P-3}: System zapewni przeciwnikom poruszanie się w linii prostej do wybranego celu.
    \item \textbf{WF-P-4}: System implementuje unikanie przeszkód przez przeciwników.
    \item \textbf{WF-P-5}: System zwiększa trudność co 1 minutę poprzez mnożnik wykładniczy $1.1^{minutes}$.
    \item \textbf{WF-P-6}: System wprowadza nowe tiery przeciwników co 3 minuty z mnożnikiem $1.5^{tier}$.
    \item \textbf{WF-P-7}: System spawmuje niebieskie kwadraty po eliminacji każdego przeciwnika.
    \item \textbf{WF-P-8}: System wyświetla numery obrażeń nad przeciwnikami przy otrzymaniu obrażeń.
\end{enumerate}

\subsubsection{Moduł budowania struktur}
\begin{enumerate}
    \item \textbf{WF-B-1}: System umożliwi wybór typu struktury do budowy z menu (przyciski UI).
    \item \textbf{WF-B-2}: System wyświetli półprzezroczysty podgląd struktury podążający za kursorem myszy.
    \item \textbf{WF-B-3}: System waliduje możliwość postawienia struktury (sprawdzenie kolizji, odległości od innych obiektów).
    \item \textbf{WF-B-4}: System wyświetli wizualny feedback (kolor zielony/czerwony) dla poprawności miejsca.
    \item \textbf{WF-B-5}: System umożliwi potwierdzenie budowy lewym przyciskiem myszy.
    \item \textbf{WF-B-6}: System umożliwi anulowanie budowy prawym przyciskiem myszy.
    \item \textbf{WF-B-7}: System umożliwi rotację barykad klawiszem Q w trybie budowania.
    \item \textbf{WF-B-8}: System odejmie odpowiednią ilość zasobów po postawieniu struktury.
    \item \textbf{WF-B-9}: System zapobiegnie budowaniu gdy gracz ma niewystarczającą ilość zasobów.
    \item \textbf{WF-B-10}: System blokuje zakup dronów gdy maksymalna liczba (5) została osiągnięta.
\end{enumerate}

\subsubsection{Moduł struktur obronnych}

\begin{enumerate}
    \item \textbf{WF-S-1}: Wieże automatycznie wykrywają przeciwników w zasięgu i atakują najbliższego.
    \item \textbf{WF-S-2}: Wieże posiadają cooldown między strzałami modyfikowalny przez ulepszenia.
    \item \textbf{WF-S-3}: Barykady blokują ruch przeciwników i gracza.
    \item \textbf{WF-S-4}: Miny eksplodują gdy wróg wejdzie w zasięg detekcji lub natychmiast jeśli wróg jest już w zasięgu.
    \item \textbf{WF-S-5}: Eksplozja miny zadaje obrażenia obszarowe wszystkim wrogom w promieniu.
    \item \textbf{WF-S-6}: Drony orbitują wokół gracza w równych odstępach kątowych.
    \item \textbf{WF-S-7}: Drony automatycznie atakują najbliższych przeciwników.
    \item \textbf{WF-S-8}: Wszystkie struktury posiadają punkty życia z wyjątkiem miny i mogą zostać zniszczone.
    \item \textbf{WF-S-9}: Struktury wyświetlają paski życia i numery obrażeń gdy otrzymują obrażenia.
\end{enumerate}

\subsubsection{Moduł progresji i ulepszeń}

\begin{enumerate}
    \item \textbf{WF-U-1}: System śledzi doświadczenie gracza i aktualny poziom.
    \item \textbf{WF-U-2}: System zatrzymuje grę i wyświetla menu ulepszeń po zdobyciu poziomu.
    \item \textbf{WF-U-3}: System oferuje 3 losowe ulepszenia do wyboru przy każdym poziomie.
    \item \textbf{WF-U-4}: Ulepszenia stackują się multiplikatywnie ($multiplier \times 1.1$).
    \item \textbf{WF-U-5}: Ulepszenia wież/dronów/min wpływają zarówno na istniejące jak i przyszłe obiekty.
    \item \textbf{WF-U-6}: System przechowuje globalne mnożniki w singleton GameStats.
    \item \textbf{WF-U-7}: System nie posiada górnego limitu poziomów.
\end{enumerate}

\subsubsection{Moduł zarządzania zasobami}

\begin{enumerate}
    \item \textbf{WF-Z-1}: System wyświetla aktualną ilość posiadanych zasobów w UI.
    \item \textbf{WF-Z-2}: Zasoby pozostają na ziemi przez 30 sekund przed zniknięciem.
    \item \textbf{WF-Z-3}: System automatycznie zbiera zasoby gdy gracz znajdzie się w zasięgu magnesu.
    \item \textbf{WF-Z-4}: System umożliwia naprawę bazy za zasoby gdy gracz stoi obok bazy.
\end{enumerate}

\subsection{Wymagania niefunkcjonalne}

\subsubsection{Wymagania wydajnościowe}

\begin{enumerate}
    \item \textbf{WN-W-1}: Gra będzie działała płynnie przy 60 FPS na rozdzielczości 640x360.
    \item \textbf{WN-W-2}: System obsłuży jednocześnie co najmniej 100 przeciwników bez spadku wydajności.
    \item \textbf{WN-W-3}: System spawmowania przeciwników nie będzie powodował lag spikes.
    \item \textbf{WN-W-4}: System kolizji będzie działał sprawnie przy wielu obiektach na scenie.
\end{enumerate}

\subsubsection{Wymagania sprzętowe}

\begin{enumerate}
    \item \textbf{WN-S-1}: Gra będzie działała na komputerze z procesorem co najmniej 2-rdzeniowym i 4 GB RAM.
    \item \textbf{WN-S-2}: Gra będzie wymagała karty graficznej obsługującej OpenGL 3.3 lub nowszy.
    \item \textbf{WN-S-3}: Gra będzie wymagała co najmniej 500 MB wolnego miejsca na dysku.
    \item \textbf{WN-S-4}: Gra będzie działała na systemach Windows, macOS i Linux.
\end{enumerate}

\subsubsection{Wymagania technologiczne}

\begin{enumerate}
    \item \textbf{WN-T-1}: Gra zostanie zaimplementowana w języku GDScript w silniku Godot 4.5.
    \item \textbf{WN-T-2}: Gra będzie wykorzystywała architekturę opartą na nodach (node-based architecture).
    \item \textbf{WN-T-3}: Gra będzie wykorzystywała system sygnałów do komunikacji między obiektami.
    \item \textbf{WN-T-4}: Gra będzie wykorzystywała singleton pattern dla globalnego stanu gry (GameStats).
\end{enumerate}

\subsection{Syntetyczny opis funkcjonalny}

Gra roguelike z elementami tower defense została zaprojektowana jako hybrydowe rozwiązanie łączące automatyczne mechaniki survivala z aktywnym budowaniem struktur obronnych. Gra obsługuje wszystkie kluczowe mechaniki gatunku wraz z innowacyjnym systemem progresji wykładniczej.

System rozgrywki głównej zapewnia płynne sterowanie postacią, automatyczne zbieranie zasobów oraz dynamiczny system targeto wania przeciwników. Gracze muszą zarządzać zarówno swoją pozycją, jak i zasobami potrzebnymi do budowy struktur obronnych.

System budowania umożliwia strategiczne rozmieszczanie wież, barykad, min oraz zakup dronów. Każda struktura pełni unikalną rolę i może być ulepszona przez system progresji.

\end{document}
