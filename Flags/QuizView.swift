import SwiftUI

class QuizTimer: ObservableObject {
    @Published var timeRemaining: Int
    private var timer: Timer?
    private let timePerQuestion: Int
    var onTimeUp: (() -> Void)?

    init(timePerQuestion: Int) {
        self.timePerQuestion = timePerQuestion
        self.timeRemaining = timePerQuestion
    }

    func start() {
        timer?.invalidate()
        timeRemaining = timePerQuestion
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.onTimeUp?()
            }
        }
    }

    func stop() {
        timer?.invalidate()
    }

    deinit {
        timer?.invalidate()
    }
}

struct QuizView: View {
    let region: String
    let questionCount: Int
    let timePerQuestion: Int
    let countries: [Country]

    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var currentCountry: Country
    @State private var options: [Country]
    @StateObject private var timer: QuizTimer
    @State private var isGameOver = false
    @State private var selectedAnswer: String?
    @State private var isAnswerLocked = false

    init(region: String, questionCount: Int, timePerQuestion: Int, countries: [Country]) {
        self.region = region
        self.questionCount = questionCount
        self.timePerQuestion = timePerQuestion
        let shuffled = countries.shuffled()
        self.countries = Array(shuffled.prefix(questionCount))
        self._currentCountry = State(initialValue: self.countries[0])
        self._options = State(initialValue: Self.generateOptions(from: countries, correct: self.countries[0]))
        self._timer = StateObject(wrappedValue: QuizTimer(timePerQuestion: timePerQuestion))
    }

    var body: some View {
        Group {
            if isGameOver {
                QuizResultView(score: score, total: questionCount, region: region)
            } else {
                ZStack {
                    Color.backgroundGray.ignoresSafeArea()

                    VStack(spacing: 20) {
                        header
                        flagDisplay
                        answerGrid
                        Spacer()
                        timerCircle
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isGameOver = true
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onAppear {
                    timer.onTimeUp = {
                        if !isAnswerLocked {
                            selectAnswer("") // No answer = incorrect
                        }
                    }
                    timer.start()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question \(currentQuestion + 1)/\(questionCount)")
                .font(.title)
                .bold()
                .foregroundColor(.black)
            Text("Score: \(score)")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 20)
    }

    private var flagDisplay: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .shadow(radius: 5)

            Text(currentCountry.flag)
                .font(.system(size: 120))
        }
        .padding()
    }

    private var answerGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(options, id: \.id) { country in
                Button(action: {
                    if !isAnswerLocked {
                        selectAnswer(country.name)
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
                                .fill(buttonBackground(for: country.name))
                                .shadow(color: buttonBackground(for: country.name).opacity(0.5), radius: 10, x: 0, y: 5)
                        )
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var timerCircle: some View {
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

    private func buttonBackground(for countryName: String) -> Color {
        guard let selected = selectedAnswer else {
            return .glowingBlue
        }

        if countryName == currentCountry.name {
            return .glowingGreen
        }
        if countryName == selected {
            return .glowingRed
        }
        return .glowingBlue
    }

    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswerLocked = true
        timer.stop()

        if answer == currentCountry.name {
            score += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            nextQuestion()
        }
    }

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

    private static func generateOptions(from countries: [Country], correct: Country) -> [Country] {
        var options = [correct]
        let others = countries.filter { $0.id != correct.id }
        options.append(contentsOf: others.shuffled().prefix(3))
        return options.shuffled()
    }

    private var timerColor: Color {
        timer.timeRemaining <= 5 ? .red : .green
    }
}


