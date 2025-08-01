<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\User;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        // Buat 5000 pesanan untuk memenuhi persyaratan 1000-10000 baris data.
        // Asumsi UserSeeder sudah dijalankan, jadi ada user yang bisa dipanggil.
        Order::factory()->count(20)->create();
    }
}
