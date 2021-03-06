function [U,P]=WCLeastSquaresCurve(Q,r,Wq,D,s,I,Wd,n,p)

x=Q(:,1);
y=Q(:,2);

xd=D(:,1);
yd=D(:,2);

ru=-1;
rc=-1;
for i=0:r
    if Wq(i+1)>0
ru=ru+1;
    else
        rc=rc+1;
    end
    end
su=-1;
sc=-1;
for j=0:s
    if Wd(j+1)>0
        su=su+1;
    else
        sc=sc+1;
    end
end
mu=ru+su+1;
mc=rc+sc+1;
if mc>=n || mc+n>=mu+1
    display('Error')
end

%Compute and load parameters u_k into ub[] (Eq.[9.5]);
for i=1:r
dd(i)=sqrt(abs([x(i+1,:)-x(i,:)]^2+[y(i+1,:)-y(i,:)]^2));
end
d_tot=sum(dd);
u_k=zeros(r+1,1)';
u_k(1)=0;
u_k(numel(x))=1;
for i=1:(r-1)
u_k(i+1)=u_k(i)+dd(i)/d_tot;
end
ub=u_k;

%Compute and load the knots into U[] (Eqs.[9.68],[9.69]);
d=(r+1)/(n-p+1);
nn=n+p+2;
U=zeros(1,nn);

for j=1:n-p
    i=ceil(j*d);
    alpha=j*d-i;
    U(p+j+1)=(1-alpha)*ub(i)+alpha*ub(i+1);
end

    for jj=1:nn
        if jj<=p+1
            U(1,jj)=0;
        elseif jj>=nn-p
            U(1,jj)=1;
        end
    end
   %Now set up arrays N,W,S,T,M
   
j=0;
mu2=0;
mc2=0;
N=zeros(mu+1,n+1);
M=zeros(mc+1,n+1);
% I=[0 1 3 4 5 6];
   for i=0:r
%i=1;
       span=findspan(n+1,p,ub(i+1),U);
       dflag=0;
       if j<=s
           if i==I(j+1)
               dflag=1;
           end
       end
            funs=zeros(1,n+1);
           if dflag==0
            funs(1,span-p+1:span+1)=basisfuncs(span,ub(i+1),p,U);
           else
            funs1=DersBasisFunction(span,ub(i+1),p,1,U);
            funs(1,span-p+1:span+1)=funs1(1,:);
           end
           
           if (Wq(i+1)>0)                %Unconstrained points
               W(mu2+1)=Wq(i+1);
               %Load the mu2th row of N[][] from funs[0][];
               N(mu2+1,:)=funs(1,:);
               x_S(mu2+1)=W(mu2+1)*x(i+1);
               y_S(mu2+1)=W(mu2+1)*y(i+1);
               mu2=mu2+1;
           else                        %Constrained points
               %Load the mc2th row of M[][] from funs [0][];
               M(mc2+1,:)=funs(1,:);
               x_T(mc2+1)=x(i+1);
               y_T(mc2+1)=y(i+1);
               mc2=mc2+1;
           end  
             if dflag==1
                 % Derivative at this point 
                 if Wd(j+1,1)>0
                     %Unconstrained derivative
                     W(mu2+1)=Wd(j+1);
                     %Load the mu2th orw from funs[1][]
                     N(mu2+1,:)=funs(1,:);
                     xd_S(mu2+1)=W(mu2+1)*xd(j+1);
                     yd_S(mu2+1)=W(mu2+1)*yd(j+1);
                     mu2=mu2+1;
                 
             else %constrained derivative
             M(mc2+1,:)=funs(1,:);
             x_T(mc2+1)=xd(j+1);
             y_T(mc2+1)=yd(j+1);
             mc2=mc2+1;  
                 end
         j=j+1;             
          end
   end
   W=diag(W);
  
   NN=N'*W*N;
   x_SS=N'*W*x_S';
   y_SS=N'*W*y_S';
% 
   [L,UU]=lu(NN);
   xx_SS=avanti(L,x_SS);
   yy_SS=avanti(L,y_SS);
   NN_inv=inv(NN);
   if mc<0
       x_P=indietro(UU,xx_SS);
       y_P=indietro(UU,yy_SS);
   else
   
MM=M*NN_inv*M';

x_NS=N'*W*x_S';
y_NS=N'*W*y_S';
x_MMM=M*NN_inv*x_NS-x_T;
y_MMM=M*NN_inv*y_NS-y_T;

MM_inv=inv(MM);
x_A=MM_inv*x_MMM;
y_A=MM_inv*y_MMM;

x_P=NN_inv*(x_NS-M'*x_A);
y_P=NN_inv*(y_NS-M'*y_A);
   end
P=[x_P y_P];
end