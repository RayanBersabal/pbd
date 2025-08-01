<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        Schema::disableForeignKeyConstraints();

        DB::table('users')->truncate();
        DB::table('products')->truncate();
        DB::table('orders')->truncate();
        DB::table('order_items')->truncate();
        DB::table('reviews')->truncate();
        DB::table('carts')->truncate();

        $this->call([
            UserSeeder::class,
            ProductSeeder::class,
            OrderSeeder::class,
            OrderItemSeeder::class,
            ReviewSeeder::class,
            CartSeeder::class,
        ]);

        Schema::enableForeignKeyConstraints();
    }
}
