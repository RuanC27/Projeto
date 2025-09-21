from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, relationship, sessionmaker

engine = create_engine("sqlite:///:memory:", echo=False)
Base = declarative_base()
Session = sessionmaker(bind=engine)
session = Session()

class Cliente(Base):
    __tablename__ = "clientes"
    id = Column(Integer, primary_key=True)
    nome = Column(String, nullable=False)
    enderecos = relationship("Endereco", back_populates="cliente", cascade="all, delete-orphan")
    def __repr__(self):
        return f"Cliente(id={self.id}, nome='{self.nome}')"

class Endereco(Base):
    __tablename__ = "enderecos"
    id = Column(Integer, primary_key=True)
    rua = Column(String, nullable=False)
    cidade = Column(String, nullable=False)
    cliente_id = Column(Integer, ForeignKey("clientes.id"))
    cliente = relationship("Cliente", back_populates="enderecos")
    def __repr__(self):
        return f"Endereco(id={self.id}, rua='{self.rua}', cidade='{self.cidade}')"

Base.metadata.create_all(engine)

cliente1 = Cliente(nome="João Silva")
cliente1.enderecos = [
    Endereco(rua="Rua A", cidade="São Paulo"),
    Endereco(rua="Rua B", cidade="Campinas")
]

cliente2 = Cliente(nome="Maria Souza")
cliente2.enderecos = [Endereco(rua="Av. Central", cidade="Rio de Janeiro")]

session.add_all([cliente1, cliente2])
session.commit()

print("\n--- Listando clientes ---")
for cliente in session.query(Cliente).all():
    print(cliente, cliente.enderecos)

print("\n--- Atualizando cliente ---")
cliente1.nome = "João Pedro Silva"
session.commit()
print(session.query(Cliente).filter_by(id=cliente1.id).first())

print("\n--- Excluindo cliente ---")
session.delete(cliente2)
session.commit()
print(session.query(Cliente).all())

print("\n--- Consulta com JOIN ---")
resultado = (
    session.query(Cliente.nome, Endereco.rua, Endereco.cidade)
    .join(Endereco)
    .all()
)

for r in resultado:
    print(r)
