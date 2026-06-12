// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imgUrl: fields[3] as String,
      price: fields[4] as double,
      discountedPrice: fields[5] as double,
      category: fields[6] as String,
      rating: fields[7] as double,
      reviewCount: fields[8] as int,
      titleAr: fields[9] as String?,
      descriptionAr: fields[10] as String?,
      images: (fields[11] as List?)?.cast<String>(),
      isOutOfStock: fields[12] as bool?,
      colors: (fields[13] as List?)?.cast<String>(),
      sizes: (fields[14] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imgUrl)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.discountedPrice)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.reviewCount)
      ..writeByte(9)
      ..write(obj.titleAr)
      ..writeByte(10)
      ..write(obj.descriptionAr)
      ..writeByte(11)
      ..write(obj.images)
      ..writeByte(12)
      ..write(obj.isOutOfStock)
      ..writeByte(13)
      ..write(obj.colors)
      ..writeByte(14)
      ..write(obj.sizes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
