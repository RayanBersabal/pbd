<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // User Admin
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@santapin.com',
            'password' => Hash::make('password'),
            'phone' => '089876543210',
            'address' => 'Jl. Admin No. 1',
            'role' => 'admin',
        ]);

        // User Regular (10 user)
        User::factory()->count(10)->create();
    }
}
