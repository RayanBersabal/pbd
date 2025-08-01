<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Review;
use App\Models\User;
use App\Models\Product;

class ReviewSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil semua user dan product yang ada
        $users = User::all();
        $products = Product::all();

        $numReviews = 20; // Jumlah ulasan yang ingin Anda buat

        // Buat array untuk menyimpan kombinasi unik user_id dan product_id
        $reviewPairs = [];

        // Buat 50 kombinasi unik secara acak
        while (count($reviewPairs) < $numReviews) {
            $user = $users->random();
            $product = $products->random();
            $pair = $user->id . '-' . $product->id;

            // Pastikan kombinasi belum ada di array
            if (!in_array($pair, $reviewPairs)) {
                $reviewPairs[] = $pair;

                // Buat ulasan menggunakan kombinasi unik ini
                Review::factory()->create([
                    'user_id' => $user->id,
                    'product_id' => $product->id,
                ]);
            }
        }
    }
}
