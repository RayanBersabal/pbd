<?php

namespace Database\Factories;

use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        $categories = ['Makanan', 'Minuman'];
        return [
            'name' => fake()->unique()->words(3, true),
            'description' => fake()->paragraph(),
            'price' => fake()->numberBetween(5000, 150000),
            'category' => fake()->randomElement($categories),
            'image' => 'products/' . fake()->slug() . '.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}
