import SwiftUI

// Klasse zur Verwaltung eines Countdowns für jede Quizfrage
class QuizTimer: ObservableObject {
    @Published var timeRemaining: Int               // Verbleibende Zeit
    private var timer: Timer?                       // Interner Timer
    private let timePerQuestion: Int                // Zeitlimit pro Frage
    var onTimeUp: (() -> Void)?                     // Callback, wenn Zeit abläuft

    // Initialisiert den Timer mit der Zeit pro Frage
    init(timePerQuestion: Int) {
        self.timePerQuestion = timePerQuestion
        self.timeRemaining = timePerQuestion
    }

    // Startet den Timer und zählt jede Sekunde runter
    func start() {
        timer?.invalidate()                         // Vorherigen Timer stoppen
        timeRemaining = timePerQuestion             // Zeit zurücksetzen
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1             // Zeit herunterzählen
            } else {
                self.timer?.invalidate()            // Timer stoppen, wenn Zeit abgelaufen ist
                self.onTimeUp?()                    // Callback ausführen
            }
        }
    }

    // Stoppt den Timer
    func stop() {
        timer?.invalidate()
    }

    // Wird aufgerufen, wenn die Instanz gelöscht wird (z. B. wenn das QuizView verlassen wird)
    deinit {
        timer?.invalidate()
    }
}

struct QuizView: View {
    // Quiz-Parameter und Daten
    let region: String
    let questionCount: Int
    let timePerQuestion: Int
    let countries: [Country]

    // Zustände für Quiz-Fortschritt und Benutzerinteraktion
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var currentCountry: Country
    @State private var options: [Country]
    @StateObject private var timer: QuizTimer
    @State private var isGameOver = false
    @State private var selectedAnswer: String?
    @State private var correctAnswer: String?
    @State private var isAnswerLocked = false
    @Environment(\.presentationMode) var presentationMode

    // Initialisiert das Quiz mit den übergebenen Ländern und setzt die erste Frage
    init(region: String, questionCount: Int, timePerQuestion: Int, countries: [Country]) {
        self.region = region
        self.questionCount = questionCount
        self.timePerQuestion = timePerQuestion

        let shuffledCountries = countries.shuffled()
        self.countries = Array(shuffledCountries.prefix(questionCount))

        self._currentCountry = State(initialValue: self.countries[0])
        self._options = State(initialValue: Self.generateOptions(from: countries, correct: self.countries[0]))
        self._timer = StateObject(wrappedValue: QuizTimer(timePerQuestion: timePerQuestion))
    }

    var body: some View {
        if isGameOver {
            // Anzeige der Ergebnisansicht nach dem Quiz
            QuizResultView(score: score, total: questionCount)
        } else {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Frage-Header (Fragenummer + Punktestand)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question \(currentQuestion + 1)/\(questionCount)")
                            .font(.title)
                            .foregroundColor(.black)
                            .bold()
                        Text("Score: \(score)")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)  // Zusätzlicher Abstand nach oben

                    // Flagge als Emoji-Anzeige
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 5)

                        Text(currentCountry.flag)
                            .font(.system(size: 120))
                    }
                    .padding()

                    // Antwortmöglichkeiten in 2x2 Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(options, id: \.id) { country in
                            Button(action: {
                                if !isAnswerLocked {
                                    selectAnswer(country.name) // Antwort auswählen
                                }
                            }) {
                                Text(country.name)
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 85)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(buttonBackground(for: country.name)) // Hintergrundfarbe je nach Auswahl
                                            .shadow(color: buttonBackground(for: country.name).opacity(0.5), radius: 10, x: 0, y: 5)
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    Spacer()

                    // Timer als Kreis unten
                    ZStack {
                        Circle()
                            .stroke(timerColor.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: CGFloat(timer.timeRemaining) / CGFloat(timePerQuestion))
                            .stroke(timerColor, lineWidth: 8)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))

                        Text("\(timer.timeRemaining)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(timerColor)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // Zurück-Button
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            })
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .onAppear {
                // Timer starten, wenn View erscheint
                timer.onTimeUp = {
                    if !isAnswerLocked {
                        selectAnswer("") // Keine Antwort → "falsch"
                    }
                }
                timer.start()
            }
        }
    }

    // Bestimmt die Hintergrundfarbe der Antwort-Buttons je nach Auswahlstatus
    private func buttonBackground(for countryName: String) -> Color {
        guard let selected = selectedAnswer else {
            return .glowingBlue
        }

        if countryName == currentCountry.name {
            return selected == countryName ? .glowingGreen : .glowingGreen
        }
        if countryName == selected {
            return .glowingRed
        }
        return .glowingBlue
    }

    // Behandelt die Auswahl einer Antwort
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswerLocked = true
        timer.stop()

        if answer == currentCountry.name {
            score += 1 // Richtige Antwort → Punkt
        }

        // Nach kurzer Verzögerung zur nächsten Frage springen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            nextQuestion()
        }
    }

    // Wechselt zur nächsten Frage oder beendet das Spiel
    private func nextQuestion() {
        if currentQuestion < questionCount - 1 {
            currentQuestion += 1
            currentCountry = countries[currentQuestion]
            options = Self.generateOptions(from: countries, correct: currentCountry)
            selectedAnswer = nil
            isAnswerLocked = false
            timer.start()
        } else {
            isGameOver = true
        }
    }

    // Erstellt eine zufällige Liste von 4 Antwortmöglichkeiten (inkl. korrekter)
    private static func generateOptions(from countries: [Country], correct: Country) -> [Country] {
        var options = [correct]
        let otherCountries = countries.filter { $0.id != correct.id }
        options.append(contentsOf: otherCountries.shuffled().prefix(3))
        return options.shuffled()
    }

    // Farbe des Timers je nach verbleibender Zeit
    private var timerColor: Color {
        timer.timeRemaining <= 5 ? .red : .green
    }
}

