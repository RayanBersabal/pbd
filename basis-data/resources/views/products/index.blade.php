@extends('layouts.app')

@section('content')
<div class="container mx-auto p-6">
  <h2 class="text-2xl font-semibold mb-4">Daftar Produk</h2>

  <a href="{{ route('products.create') }}" class="mb-4 inline-block bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
    Tambah Produk
  </a>

  <table class="min-w-full border rounded shadow">
    <thead class="bg-gray-200">
      <tr>
        <th class="p-3 text-left">Nama</th>
        <th class="p-3 text-left">Harga</th>
        <th class="p-3 text-left">Kategori</th>
        <th class="p-3 text-left">Aksi</th>
      </tr>
    </thead>
    <tbody class="bg-white">
      @foreach($products as $product)
      <tr class="border-t">
        <td class="p-3">{{ $product->name }}</td>
        <td class="p-3">Rp{{ number_format($product->price) }}</td>
        <td class="p-3">{{ $product->category }}</td>
        <td class="p-3 space-x-2">
          <a href="{{ route('products.edit', $product->id) }}" class="text-blue-600 hover:underline">Edit</a>
          <form action="{{ route('products.destroy', $product->id) }}" method="POST" class="inline">
            @csrf
            @method('DELETE')
            <button onclick="return confirm('Yakin hapus?')" class="text-red-600 hover:underline">Hapus</button>
          </form>
        </td>
      </tr>
      @endforeach
    </tbody>
  </table>
</div>
@endsection
