@extends('layouts.app')

@section('content')
<div class="max-w-xl mx-auto p-6 bg-white rounded shadow">
  <h2 class="text-2xl font-semibold mb-4">Edit Produk</h2>

  @if ($errors->any())
    <div class="mb-4 p-4 bg-red-100 text-red-600 rounded">
      <ul class="list-disc list-inside">
        @foreach ($errors->all() as $error)
          <li>{{ $error }}</li>
        @endforeach
      </ul>
    </div>
  @endif

  <form action="{{ route('products.update', $product->id) }}" method="POST" class="space-y-4">
    @csrf
    @method('PUT')

    <div>
      <label class="block font-medium">Nama:</label>
      <input type="text" name="name" value="{{ $product->name }}"
             class="w-full border rounded px-3 py-2">
    </div>

    <div>
      <label class="block font-medium">Harga:</label>
      <input type="number" name="price" value="{{ $product->price }}"
             class="w-full border rounded px-3 py-2">
    </div>

    <div>
      <label class="block font-medium">Kategori:</label>
      <select name="category" class="w-full border rounded px-3 py-2">
        <option value="Makanan" @if($product->category == 'Makanan') selected @endif>Makanan</option>
        <option value="Minuman" @if($product->category == 'Minuman') selected @endif>Minuman</option>
      </select>
    </div>

    <div>
      <label class="block font-medium">Deskripsi:</label>
      <textarea name="description" class="w-full border rounded px-3 py-2">{{ $product->description }}</textarea>
    </div>

    <button type="submit"
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition">
      Update
    </button>
  </form>
</div>
@endsection
