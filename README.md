# Uni Q&A Mobile App
*A cross-platform mobile app developed using Flutter Framework with a target group of **students/pupils**.*

## ✨Product Highlights
- 📱**Feed View** - all the questions are structured in modern widely used feed format in order to provide familiar experience to the other mostly used apps.
- 🎯**Flat Hierarchy** - Most important features are just one click away.
- 📊**Statistics** - Statistical information about user's engagement in the app is presented in easily accessible section.
- ⚖️**Users decide the fate of the posts** - Users can answer, provide explanations or just vote up/down to published questions.
<br><br> 
## 🚀 Workflow
1. **Brainstorming** - started with a bunch of random ideas(wild ideas was encouraged).
2. Consulting with other independent people who gave their feedback and opinion about their favourite app concept which was presented to them.
3. Development Team finally weighted all the advantages and disadvantages of all app regarding to the feedback of asked people and finally started builing on the idea of the chosen idea.
4. **Prototyping** - the rough idea was drew on paper, details were missing.
5. After another consulting with possible future users of the app, some of the functions were scrached and other were figured out (Design underwent some changes).
6. **Final Prototype** was finally figured.
7. **Coding** - Paper Prototype was converted to code.
8. **Test & Bug Fixing** - All the functionalities and features were tested and some bugs were successfully fixed.

> More detailed information about the whole process can be found in this **[document](https://github.com/talasumaa/Uni-Q-A-Mobile-App/blob/main/Lab5_dossier.docx)**.
<br><br> 
## 📂 Project Structure
``` plaintext
uni-qa-mobile-app/
├─ android/
├─ ios/
├─ lib/
│  ├─ app/
│  │  ├─ app_state.dart
│  │  ├─ app.dart
│  │  └─ root_shell.dart
│  ├─ data/
│  │  └─ qna_repository.dart
│  ├─ models/
│  │  ├─ answer.dart
│  │  ├─ app_user.dart
│  │  ├─ feed_sort.dart
│  │  └─ question.dart
│  ├─ screens/
│  │  ├─ add_answer_screen.dart
│  │  ├─ ask_question_screen.dart
│  │  ├─ feed_screen.dart
│  │  ├─ login_screen.dart
│  │  ├─ profile_screen.dart
│  │  └─ question_detail_screen.dart
│  ├─ utils/
│  │  ├─ snack.dart
│  │  └─ time_ago.dart
│  ├─ widgets/
│  │  ├─ answer_card.dart
│  │  ├─ empty_box.dart
│  │  ├─ mini_chip.dart
│  │  ├─ question_card.dart
│  │  └─ stat_tile.dart
│  └─ main.dart
├─ linux/
├─ macos/
├─ web/
├─ windows/
├─ .gitignore
├─ .metadata
├─ analysis_options.yaml
├─ Lab5_dossier.docx
├─ pubspec.lock
├─ pubspec.yaml
└─ README.md
```
