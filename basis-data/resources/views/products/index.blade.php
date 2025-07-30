@extends('layouts.app')

@section('content')
<h2>Daftar Produk</h2>
<a href="{{ route('products.create') }}">Tambah Produk</a>
<table border="1">
  <tr>
    <th>Nama</th>
    <th>Harga</th>
    <th>Kategori</th>
    <th>Aksi</th>
  </tr>
  @foreach($products as $product)
  <tr>
    <td>{{ $product->name }}</td>
    <td>Rp{{ number_format($product->price) }}</td>
    <td>{{ $product->category }}</td>
    <td>
      <a href="{{ route('products.edit', $product->id) }}">Edit</a> |
      <form action="{{ route('products.destroy', $product->id) }}" method="POST" style="display:inline;">
        @csrf
        @method('DELETE')
        <button onclick="return confirm('Yakin hapus?')">Hapus</button>
      </form>
    </td>
  </tr>
  @endforeach
</table>
@endsection
