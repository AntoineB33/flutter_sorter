import 'package:flutter/material.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';

class User {
  double weightKg;
  double heightCm; // You'll need to input this
  int age;
  String gender;
  double activityLevel; // 1.2 (sedentary) to 1.9 (athlete)

  User(this.weightKg, this.heightCm, this.age, this.gender, this.activityLevel);

  // 1. Calculate BMR (Mifflin-St Jeor)
  double get bmr {
    // Formula for Men
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  }

  // 2. Calculate Maintenance Calories
  double get tdee => bmr * activityLevel;

  // 3. Calculate "Belly Burn" Target (Deficit)
  double get dailyCalorieTarget => tdee - 500;

  // 4. Calculate Macro Split (High Protein Focus)
  Map<String, int> get macros {
    // 2g protein per kg is ideal for preserving muscle in a deficit
    double proteinGrams = weightKg * 2.0; 
    double fatGrams = weightKg * 0.8;
    
    // Remaining calories go to Carbs
    // Protein/Carbs = 4 kcal/g, Fat = 9 kcal/g
    double proteinCal = proteinGrams * 4;
    double fatCal = fatGrams * 9;
    double remainingCal = dailyCalorieTarget - (proteinCal + fatCal);
    double carbGrams = remainingCal / 4;

    return {
      "Protein (g)": proteinGrams.round(),
      "Fats (g)": fatGrams.round(),
      "Carbs (g)": carbGrams.round(),
      "Total Calories": dailyCalorieTarget.round(),
    };
  }
}

class Recipe {
  String name;
  int calories;
  int protein;
  int carbs;
  int fats;

  Recipe(this.name, this.calories, this.protein, this.carbs, this.fats);
}

void main() {
  // Example: 24yo Male, 82.2kg, Est 180cm, Moderately Active (workout 3-4x/week)
  User me = User(82.2, 180, 24, 'male', 1.55);

  print("--- DAILY TARGETS ---");
  print(me.macros);
  
  // Example Logic: Find a dinner that fits remaining macros
  // You would iterate through your database here to find the closest match
}

class FoodPlanPage extends StatelessWidget {
  const FoodPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavigationDropdown(),
      body: Center(
        child: Text(
          'Welcome to the Food Plan Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
