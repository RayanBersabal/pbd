@extends('layouts.app')

@section('content')
<div class="max-w-xl mx-auto p-6 bg-white rounded shadow">
  <h2 class="text-2xl font-semibold mb-4">Tambah Produk Baru</h2>

  @if ($errors->any())
    <div class="mb-4 p-4 bg-red-100 text-red-600 rounded">
      <ul class="list-disc list-inside">
        @foreach ($errors->all() as $error)
          <li>{{ $error }}</li>
        @endforeach
      </ul>
    </div>
  @endif

  <form action="{{ route('products.store') }}" method="POST" class="space-y-4">
    @csrf

    <div>
      <label class="block font-medium">Nama:</label>
      <input type="text" name="name" class="w-full border rounded px-3 py-2">
    </div>

    <div>
      <label class="block font-medium">Harga:</label>
      <input type="number" name="price" class="w-full border rounded px-3 py-2">
    </div>

    <div>
      <label class="block font-medium">Kategori:</label>
      <select name="category" class="w-full border rounded px-3 py-2">
        <option value="Makanan">Makanan</option>
        <option value="Minuman">Minuman</option>
      </select>
    </div>

    <div>
      <label class="block font-medium">Deskripsi:</label>
      <textarea name="description" class="w-full border rounded px-3 py-2"></textarea>
    </div>

    <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Simpan</button>
  </form>
</div>
@endsection
