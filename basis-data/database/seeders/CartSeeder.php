<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Cart;
use App\Models\User;
use App\Models\Product;

class CartSeeder extends Seeder
{
    public function run(): void
    {
        // Asumsi user dan produk sudah ada
        Cart::factory()->count(20)->create();
    }
}
